[English](../09-networking.md) | **Azərbaycanca**

# 9. nmcli ilə şəbəkə

## ❌ Səhvlər

1. Ünvan təyin olunub, amma `ipv4.method` hələ də `auto`-dur.
2. Connection dəyişdirilib, amma yenidən aktivləşdirilməyib.
3. `ipv4.addresses` prefix-siz (`/24`) yazılıb.
4. Tələbə `/etc/NetworkManager/system-connections/` içindəki faylları əllə redaktə edir və reload etmir.

## 💥 Nə baş verir

1. Interface **həm** DHCP ünvanı, **həm də** statik ünvan alır, ya da statik ünvan nəzərə alınmır.
2. `nmcli con mod` yalnız saxlanılmış profili dəyişir. `con up` və ya reboot olmadan interface-də heç nə dəyişmir.
3. Prefix olmadan nəticə nəzərdə tutduğun kimi olmur.
4. NetworkManager dəyişikliyi görmür.

## ✅ Düzgün yol

```bash
nmcli con show                                   # CONNECTION adını tap (həmişə device adı ilə eyni deyil)
nmcli con mod "System eth0" \
  ipv4.addresses 192.168.10.20/24 \
  ipv4.gateway 192.168.10.1 \
  ipv4.dns 192.168.10.1 \
  ipv4.method manual \
  connection.autoconnect yes
nmcli con up "System eth0"

hostnamectl set-hostname server1.example.com
```

> ⚠️ İmtahanda qoşulduğun interface-in IP-sini dəyişmək sessiyanı kəsə bilər.
> Task-ı iki dəfə oxu və ünvanı diqqətlə yaz.

## 🔍 Yoxla

```bash
ip -4 addr show eth0
ip route | grep default
cat /etc/resolv.conf
nmcli -g ipv4.method,connection.autoconnect con show "System eth0"
hostnamectl
```

## 💡 Qeydlər

- `nmtui` da olar. Eyni şeyin menyulu versiyasıdır və hərf səhvlərindən qoruyur.
- Faylı əllə redaktə etmisən? `nmcli con reload`, sonra `nmcli con up <ad>` işlət.
