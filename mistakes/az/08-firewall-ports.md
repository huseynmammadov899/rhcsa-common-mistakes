[English](../08-firewall-ports.md) | **Azərbaycanca**

# 8. Firewall + SELinux port-ları

Tipik task: *"Apache 82-ci portda işləməlidir."*

## ❌ Səhvlər

1. httpd.conf-da `Listen 82` yazılır, amma SELinux httpd-yə 82-ci portu açmağa hələ icazə vermir, ona görə `httpd` işə düşmür.
2. SELinux port-u düzəldilir, amma firewall açılmır. Sayt `localhost`-da işləyir, kənardan yox.
3. Firewall `--permanent` olmadan açılır, ya da `--permanent` ilə, amma `--reload` olmadan.

## 💥 Nə baş verir

**İki ayrı qapı** var. SELinux *servisin* portu istifadə edə bilib-bilməyəcəyinə, firewall isə
*trafikin* ora çata bilib-bilməyəcəyinə qərar verir. Yalnız birini düzəltmək task-ı uğursuz qoyur.
Runtime və permanent fərqi yenə [#2](02-persistence.md) səhvidir.

## ✅ Düzgün yol

```bash
# 1. servis konfiqi
sed -i 's/^Listen 80$/Listen 82/' /etc/httpd/conf/httpd.conf

# 2. SELinux: httpd-yə 82-ci portda icazə ver
semanage port -l | grep http_port_t          # artıq nəyə icazə olduğuna bax
semanage port -a -t http_port_t -p tcp 82

# 3. firewall
firewall-cmd --permanent --add-port=82/tcp
firewall-cmd --reload

# 4. servis
systemctl enable --now httpd
systemctl restart httpd                       # artıq işləyirdisə
```

## 🔍 Yoxla

```bash
ss -ltnp | grep :82
firewall-cmd --list-ports                     # runtime
firewall-cmd --permanent --list-ports         # permanent; hər ikisi 82/tcp göstərməlidir
curl -s http://localhost:82 | head -3         # lokal
curl -s http://<server-ip>:82 | head -3       # başqa maşından
```

## 💡 Qeydlər

- httpd işə düşmürsə, `journalctl -u httpd -e` `Permission denied: AH00072: make_sock` göstərir.
  Bu, hərf səhvi yox, SELinux port problemidir.
- Standart portlar üçün service istifadə et, məsələn `--add-service=http`. Qeyri-standart portlar üçün `--add-port`.
