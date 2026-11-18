[English](../03-fstab.md) | **Azərbaycanca**

# 3. /etc/fstab

## ❌ Səhv

UUID-də hərf səhvi, səhv file system tipi və ya əskik sahə. Tələbə faylı heç test etmir və birbaşa reboot edir.

## 💥 Nə baş verir

Boot zamanı systemd həmin sətri mount edə bilmir və sistem **emergency mode**-a düşür. Bir səhv
sətir bütün maşını sıradan çıxarır, artıq bitmiş task-lar da daxil olmaqla.

## ✅ Düzgün yol

```bash
blkid /dev/vg_data/lv_data          # UUID-i kopyala, əllə yenidən yazma
mkdir -p /data
vim /etc/fstab
```

```
UUID=3f2a...-...   /data   xfs    defaults   0 0
UUID=9c1b...-...   none    swap   defaults   0 0
```

Sonra **reboot etmədən test et**:

```bash
systemctl daemon-reload
findmnt --verify        # hər sətir üçün sintaksis və mövcudluq yoxlaması
mount -a                # hələ mount olunmamış hər şeyi mount edir; xətalar burada görünür
swapon -a
```

## 🔍 Yoxla

```bash
findmnt /data
swapon --show
df -hT /data
```

## 💡 Qeydlər

- `/dev/sdb1` yox, **UUID** istifadə et (LVM üçün `/dev/mapper/...`). Device adları boot-dan boot-a dəyişə bilər.
- `mount -a` yalnız mount-un işlədiyini sübut edir. Sətir səhvdirsə, amma file system artıq mount
  olunubsa, `mount -a` heç nə demir. Bu halı `findmnt --verify` tutur.
- Emergency mode-a düşsən: root kimi login ol, `mount -o remount,rw /`, `/etc/fstab`-ı düzəlt,
  `systemctl daemon-reload`, sonra reboot et.
