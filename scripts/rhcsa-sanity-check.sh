#!/usr/bin/env bash
# rhcsa-sanity-check.sh: find "works now, gone after reboot" problems on a RHEL 8/9 practice VM.
# Read-only: it changes nothing. Run as root:  sudo ./rhcsa-sanity-check.sh
#
# Exit code = number of FAIL findings (0 = clean).

set -uo pipefail

if [[ -t 1 ]]; then R=$'\e[31m'; G=$'\e[32m'; Y=$'\e[33m'; B=$'\e[1m'; N=$'\e[0m'; else R= G= Y= B= N=; fi
FAILS=0
ok()   { echo "  ${G}OK${N}    $*"; }
warn() { echo "  ${Y}WARN${N}  $*"; }
fail() { echo "  ${R}FAIL${N}  $*"; FAILS=$((FAILS + 1)); }
hdr()  { echo; echo "${B}== $* ==${N}"; }
have() { command -v "$1" >/dev/null 2>&1; }

[[ $EUID -eq 0 ]] || echo "${Y}Not root: some checks will be incomplete.${N}"

# --- 1. fstab ---------------------------------------------------------------
hdr "/etc/fstab  (mistake #3)"
if out=$(findmnt --verify --tab-file /etc/fstab 2>&1); then
  ok "findmnt --verify: no errors"
else
  fail "findmnt --verify reports problems:"; echo "$out" | sed 's/^/        /'
fi
while read -r src target fstype _; do
  [[ -z "$src" || "$src" == \#* ]] && continue
  [[ "$fstype" == swap || "$target" == none ]] && continue
  if findmnt -rn --target "$target" -o TARGET 2>/dev/null | grep -qx "$target"; then
    ok "$target is mounted"
  else
    fail "$target is in fstab but NOT mounted (try: mount -a)"
  fi
done < <(grep -vE '^\s*(#|$)' /etc/fstab)

# --- 2. swap ----------------------------------------------------------------
hdr "Swap  (mistakes #2, #3)"
fstab_swaps=$(awk '$3=="swap" && $1 !~ /^#/ {print $1}' /etc/fstab)
active=$(swapon --show=NAME --noheadings 2>/dev/null)
if [[ -z "$fstab_swaps" ]]; then
  ok "no swap entries in fstab"
else
  for s in $fstab_swaps; do
    dev=$(findfs "$s" 2>/dev/null || echo "$s")
    real=$(readlink -f "$dev")
    if echo "$active" | xargs -r -n1 readlink -f | grep -qx "$real"; then
      ok "swap $s is active"
    else
      fail "swap $s is in fstab but not active (try: swapon -a)"
    fi
  done
fi
for a in $active; do
  if ! grep -qE "^[^#].*\sswap\s" /etc/fstab; then
    warn "swap $a is active but nothing in fstab → gone after reboot"
  fi
done

# --- 3. services ------------------------------------------------------------
hdr "Services running now but NOT enabled  (mistake #2)"
found=0
while read -r unit; do
  # socket/dbus/dependency-activated units start at boot without being "enabled"
  [[ -n "$(systemctl show -p TriggeredBy --value "$unit" 2>/dev/null)" ]] && continue
  state=$(systemctl is-enabled "$unit" 2>/dev/null)
  case "$state" in
    enabled|static|alias|indirect|generated|enabled-runtime) ;;
    *) fail "$unit is running but '$state' → won't start after reboot"; found=1 ;;
  esac
done < <(systemctl list-units --type=service --state=running --no-legend --plain | awk '{print $1}' | grep -vE '^(user@|session-|getty@|serial-getty@|systemd-)')
[[ $found -eq 0 ]] && ok "every running service is enabled"
echo "  default target: $(systemctl get-default)"

# --- 4. firewall ------------------------------------------------------------
hdr "Firewall: runtime vs permanent  (mistakes #2, #8)"
if have firewall-cmd && firewall-cmd --state >/dev/null 2>&1; then
  for zone in $(firewall-cmd --get-active-zones | grep -v '^\s'); do
    for kind in services ports rich-rules; do
      split='cat'; [[ $kind != rich-rules ]] && split="tr ' ' '\n'"   # rich rules are one per line
      rt=$(firewall-cmd --zone="$zone" --list-"$kind" | eval "$split" | sort)
      pm=$(firewall-cmd --permanent --zone="$zone" --list-"$kind" | eval "$split" | sort)
      only_rt=$(comm -23 <(echo "$rt") <(echo "$pm") | grep -v '^$')
      only_pm=$(comm -13 <(echo "$rt") <(echo "$pm") | grep -v '^$')
      [[ -n "$only_rt" ]] && fail "zone $zone $kind only at RUNTIME (lost on reboot): $(echo $only_rt)"
      [[ -n "$only_pm" ]] && warn "zone $zone $kind only PERMANENT (missing --reload?): $(echo $only_pm)"
    done
  done
  ok "firewall comparison done (no lines above = runtime and permanent match)"
else
  warn "firewalld is not running"
fi

# --- 5. SELinux -------------------------------------------------------------
hdr "SELinux  (mistakes #1, #5)"
cur=$(getenforce 2>/dev/null || echo unknown)
cfg=$(awk -F= '/^SELINUX=/{print $2}' /etc/selinux/config 2>/dev/null)
[[ "$cur" == Enforcing ]] && ok "current mode: Enforcing" || fail "current mode: $cur (should be Enforcing)"
[[ "$cfg" == enforcing ]] && ok "config file: enforcing" || fail "config file: SELINUX=$cfg (should be enforcing)"
[[ -e /.autorelabel ]] && warn "/.autorelabel exists → full relabel on next boot (expected after a root password reset)"

if have restorecon; then
  for d in /var/www /srv /web /common /home /etc/shadow; do
    [[ -e "$d" ]] || continue
    diff=$(restorecon -Rnv "$d" 2>/dev/null | head -5)
    if [[ -n "$diff" ]]; then
      warn "labels under $d differ from policy (chcon or mv?). They will be reset on relabel:"
      echo "$diff" | sed 's/^/        /'
    fi
  done
  ok "label check done"
fi

# --- 6. network -------------------------------------------------------------
hdr "Network  (mistake #9)"
if have nmcli; then
  while IFS=: read -r name dev; do
    [[ -z "$dev" || "$dev" == lo ]] && continue
    ac=$(nmcli -g connection.autoconnect con show "$name" 2>/dev/null)
    method=$(nmcli -g ipv4.method con show "$name" 2>/dev/null)
    addrs=$(nmcli -g ipv4.addresses con show "$name" 2>/dev/null)
    [[ "$ac" == yes ]] && ok "'$name' ($dev) autoconnect=yes" || fail "'$name' ($dev) autoconnect=$ac → down after reboot"
    if [[ -n "$addrs" && "$method" == auto ]]; then
      warn "'$name' has static address $addrs but ipv4.method=auto (meant manual?)"
    fi
  done < <(nmcli -t -f NAME,DEVICE con show --active)
fi
static=$(cat /etc/hostname 2>/dev/null); now=$(hostname)
[[ "$static" == "$now" ]] && ok "hostname '$now' is persistent" || fail "hostname is '$now' but static is '$static' (use hostnamectl)"

# --- 7. rootless containers -------------------------------------------------
hdr "Users with linger (rootless container services, mistake #10)"
if ls /var/lib/systemd/linger/ >/dev/null 2>&1 && [[ -n "$(ls /var/lib/systemd/linger/)" ]]; then
  for u in /var/lib/systemd/linger/*; do ok "linger enabled for $(basename "$u")"; done
else
  echo "  (none, which is fine unless a task asks for a container service)"
fi

# --- summary ----------------------------------------------------------------
echo
if [[ $FAILS -eq 0 ]]; then
  echo "${G}${B}No FAIL findings. Now reboot and run this again.${N}"
else
  echo "${R}${B}$FAILS FAIL finding(s). Fix them before you reboot.${N}"
fi
exit "$FAILS"
