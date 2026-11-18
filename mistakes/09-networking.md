**English** | [Azərbaycanca](az/09-networking.md)

# 9. Networking with nmcli

## ❌ The mistakes

1. The address is set, but `ipv4.method` is still `auto`.
2. The connection is modified, but never re-activated.
3. `ipv4.addresses` is written without a prefix (`/24`).
4. The student edits files in `/etc/NetworkManager/system-connections/` by hand and doesn't reload.

## 💥 What happens

1. The interface gets **both** a DHCP address and the static one, or the static one is ignored.
2. `nmcli con mod` only changes the saved profile. Nothing changes on the interface until `con up` or a reboot.
3. Without a prefix the result isn't what you intended.
4. NetworkManager doesn't see the change.

## ✅ The right way

```bash
nmcli con show                                   # find the CONNECTION name (not always = device name)
nmcli con mod "System eth0" \
  ipv4.addresses 192.168.10.20/24 \
  ipv4.gateway 192.168.10.1 \
  ipv4.dns 192.168.10.1 \
  ipv4.method manual \
  connection.autoconnect yes
nmcli con up "System eth0"

hostnamectl set-hostname server1.example.com
```

> ⚠️ On the exam, changing the IP of the interface you're connected through can cut your session.
> Read the task twice and type the address carefully.

## ❌ Two NICs: editing the wrong one

In `nmtui` the student sees two entries, for example `Wired connection 1` and `System eth1`,
picks one by guess, and configures the address there. Everything "saves fine", but the
address ends up on the **wrong interface**, or on a profile that isn't even active.

Why it's confusing:

- `nmtui` lists **connections (profiles)**, not devices. A profile name doesn't have to match the device name.
- There can be a profile that isn't attached to any device, or two profiles for the same device.
- The task names an **interface** (`eth1`, `ens224`) or an existing IP, not a profile name.

**Find the right one before you touch anything:**

```bash
ip -br addr                              # devices, state, current IPs
nmcli device status                      # DEVICE → CONNECTION mapping  ← the key command
nmcli -f NAME,UUID,DEVICE,ACTIVE con show
nmcli -g connection.interface-name con show "Wired connection 1"   # which device a profile is bound to
```

Example `nmcli device status`:

```
DEVICE  TYPE      STATE      CONNECTION
eth0    ethernet  connected  System eth0          ← the one you're logged in through, don't touch
eth1    ethernet  connected  Wired connection 1   ← the task says eth1 → edit THIS profile
```

Then edit exactly that profile, by name:

```bash
nmcli con mod "Wired connection 1" ipv4.addresses ... ipv4.method manual
nmcli con up "Wired connection 1"
```

In `nmtui`, open **Edit a connection** and check the **Device** field at the top of the profile
before changing anything.

**Verify the address landed on the right device:** `ip -br addr show eth1`.

## 🔍 Verify

```bash
ip -4 addr show eth0
ip route | grep default
cat /etc/resolv.conf
nmcli -g ipv4.method,connection.autoconnect con show "System eth0"
hostnamectl
```

## 💡 Notes

- `nmtui` is fine too. It's a menu over the same thing and saves typos.
- Edited the file by hand? Run `nmcli con reload`, then `nmcli con up <name>`.
