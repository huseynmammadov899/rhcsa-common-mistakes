[English](../05-selinux.md) | **Azərbaycanca**

# 5. SELinux context-ləri

## ❌ Səhv

Apache-dən `/web` qovluğunu göstərməsi tələb olunur, o isə `403 Forbidden` qaytarır. Tələbə bunu işlədir:

```bash
chcon -R -t httpd_sys_content_t /web
```

İşləyir, ona görə növbəti task-a keçir. Daha pisi: `setenforce 0`.

## 💥 Nə baş verir

`chcon` diskdəki label-i dəyişir, **policy-ni yox**. Növbəti relabel köhnə label-i geri qaytarır.
Relabel isə, məsələn, root parolunun bərpasından sonra baş verir (`/.autorelabel`, bax [#1](01-root-password-reset.md)).
Reboot-dan sonra veb səhifə yenidən sınır. `setenforce 0` isə birbaşa uğursuzluqdur, çünki SELinux enforcing olmalıdır.

## ✅ Düzgün yol

```bash
semanage fcontext -a -t httpd_sys_content_t "/web(/.*)?"   # qaydanı policy-yə yaz
restorecon -Rv /web                                         # tətbiq et
```

Lazım olacaq digər SELinux alətləri:

```bash
semanage port -a -t http_port_t -p tcp 82    # servis üçün qeyri-standart port (bax #8)
setsebool -P httpd_enable_homedirs on        # boolean, -P = persistent
```

## 🔍 SELinux-un nəyi blokladığını tap

```bash
ausearch -m AVC -ts recent
journalctl -t setroubleshoot        # setroubleshoot-server quraşdırılıbsa; həll yolunu təklif edir
```

## 🔍 Yoxla

```bash
ls -Zd /web
semanage fcontext -l | grep '^/web'
matchpathcon /web                   # policy-yə görə label nə olmalıdır
restorecon -Rnv /web                # -n = dry run; boş çıxış = hər şey uyğundur
```

## 💡 Qeydlər

- Label-i işləyən bir path-dən kopyala: `semanage fcontext -a -e /var/www /web` (equivalence qaydası).
- `mv` köhnə label-i saxlayır, `cp` hədəfin label-ini alır. `/root`-dan `/var/www/html`-ə köçürülən
  fayl `admin_home_t` label-ini saxlayır və Apache onu oxuya bilmir.
