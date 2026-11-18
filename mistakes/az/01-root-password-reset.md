[English](../01-root-password-reset.md) | **Azərbaycanca**

# 1. Root parolunun bərpası

## ❌ Səhv

Tələbə `rd.break` ilə boot edir, parolu dəyişir və reboot edir, amma `touch /.autorelabel`-i unudur.

## 💥 Nə baş verir

`passwd` `/etc/shadow` faylını yenidən yazır. Bu mərhələdə SELinux policy yüklənməyib, ona görə
yeni fayl səhv label alır. Reboot-dan sonra SELinux enforcing rejimindədir və login prosesi
`/etc/shadow`-u oxuya bilmir: **heç kim login ola bilmir, yeni parolla belə.** Uzaqdan keçirilən
imtahanda bu, maşını itirmək deməkdir.

## ✅ Düzgün yol (RHEL 9)

1. Reboot et. GRUB menyusunda default sətirdə `e` bas.
2. `linux` ilə başlayan sətrin sonuna `rd.break` əlavə et. `Ctrl+x` bas.
3. Sonra:

```bash
mount -o remount,rw /sysroot
chroot /sysroot
passwd root
touch /.autorelabel        # ← unudulan sətir
exit
exit
```

Bundan sonrakı ilk boot uzun çəkir, çünki SELinux file system-i yenidən label-ləyir. Bu normaldır,
**prosesi kəsmə**.

## 🔍 Yoxla

```bash
ssh root@localhost          # və ya console-da yeni parolla login ol
getenforce                  # hələ də Enforcing olmalıdır
ls -Z /etc/shadow           # system_u:object_r:shadow_t:s0
```

## 💡 Qeydlər

- Login problemini SELinux-u permissive edərək "həll etmə". İmtahan onun enforcing olduğunu yoxlayır.
- Dəyişikliyin tətbiq olunduğuna əmin deyilsənsə, başqa heç nə etməzdən əvvəl `cat /proc/cmdline` ilə yoxla.
