**English** | [Azərbaycanca](az/02-persistence.md)

# 2. Persistence: "it worked before the reboot"

The most expensive mistake on the exam. The system is **rebooted before grading**, so anything
that exists only in memory scores zero.

## ❌ → ✅

| Area | Runtime only (lost on reboot) | Persistent |
|------|------------------------------|------------|
| Services | `systemctl start httpd` | `systemctl enable --now httpd` |
| Firewall | `firewall-cmd --add-service=http` | `firewall-cmd --permanent --add-service=http` + `--reload` |
| SELinux boolean | `setsebool httpd_enable_homedirs on` | `setsebool -P httpd_enable_homedirs on` |
| SELinux mode | `setenforce 1` | `SELINUX=enforcing` in `/etc/selinux/config` |
| Mounts | `mount /dev/vg/lv /data` | entry in `/etc/fstab` |
| Swap | `swapon /dev/vg/swap` | entry in `/etc/fstab` |
| Hostname | `hostname server1` | `hostnamectl set-hostname server1` |
| Network | `ip addr add ...` | `nmcli con mod ...` + `nmcli con up ...` |
| Kernel params | `sysctl -w ...` | file in `/etc/sysctl.d/` |
| Tuned profile | — | `tuned-adm profile <name>` (persistent by itself) |
| Default target | `systemctl isolate multi-user.target` | `systemctl set-default multi-user.target` |
| Container service | `podman run -d ...` | systemd user unit + `enable` + linger (see [#10](10-rootless-containers.md)) |

## 🔍 Verify

```bash
systemctl is-enabled httpd
firewall-cmd --permanent --list-all
getsebool httpd_enable_homedirs
grep ^SELINUX= /etc/selinux/config
systemctl get-default
```

## 💡 Habit

**Reboot your exam machine yourself**, once in the middle and once near the end, while there's
still time to fix things. Then re-check every task. Use
[`rhcsa-sanity-check.sh`](../scripts/rhcsa-sanity-check.sh) on practice VMs to train this.
