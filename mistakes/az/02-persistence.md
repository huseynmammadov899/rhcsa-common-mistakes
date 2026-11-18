[English](../02-persistence.md) | **Azərbaycanca**

# 2. Persistence: "reboot-dan əvvəl işləyirdi"

İmtahanda ən baha başa gələn səhv. Sistem **qiymətləndirmədən əvvəl reboot olunur**, ona görə
yalnız yaddaşda (runtime-da) olan hər şey sıfır bal alır.

## ❌ → ✅

| Sahə | Yalnız runtime (reboot-da itir) | Persistent |
|------|-------------------------------|------------|
| Servislər | `systemctl start httpd` | `systemctl enable --now httpd` |
| Firewall | `firewall-cmd --add-service=http` | `firewall-cmd --permanent --add-service=http` + `--reload` |
| SELinux boolean | `setsebool httpd_enable_homedirs on` | `setsebool -P httpd_enable_homedirs on` |
| SELinux rejimi | `setenforce 1` | `/etc/selinux/config`-da `SELINUX=enforcing` |
| Mount-lar | `mount /dev/vg/lv /data` | `/etc/fstab`-da sətir |
| Swap | `swapon /dev/vg/swap` | `/etc/fstab`-da sətir |
| Hostname | `hostname server1` | `hostnamectl set-hostname server1` |
| Şəbəkə | `ip addr add ...` | `nmcli con mod ...` + `nmcli con up ...` |
| Kernel parametrləri | `sysctl -w ...` | `/etc/sysctl.d/` içində fayl |
| Tuned profili | — | `tuned-adm profile <ad>` (özü persistent-dir) |
| Default target | `systemctl isolate multi-user.target` | `systemctl set-default multi-user.target` |
| Container service | `podman run -d ...` | systemd user unit + `enable` + linger (bax [#10](10-rootless-containers.md)) |

## 🔍 Yoxla

```bash
systemctl is-enabled httpd
firewall-cmd --permanent --list-all
getsebool httpd_enable_homedirs
grep ^SELINUX= /etc/selinux/config
systemctl get-default
```

## 💡 Vərdiş

**İmtahan maşınını özün reboot et**: bir dəfə ortada, bir dəfə sona yaxın, hələ düzəltməyə vaxt
varkən. Sonra hər task-ı yenidən yoxla. Bunu məşq etmək üçün təcrübə VM-lərində
[`rhcsa-sanity-check.sh`](../../scripts/rhcsa-sanity-check.sh) işlət.
