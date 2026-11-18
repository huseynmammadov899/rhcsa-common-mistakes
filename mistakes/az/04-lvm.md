[English](../04-lvm.md) | **Azərbaycanca**

# 4. LVM ölçüsünün dəyişməsi

## ❌ Səhvlər

1. File system-i böyütmədən `lvextend -L +500M /dev/vg/lv`.
2. `-L 500M` (ölçünü 500M-**ə qədər** et) ilə `-L +500M` (500M **əlavə et**) qarışdırılır.
3. XFS file system-i kiçiltməyə cəhd.
4. Task-da verilən **extent size** və ya extent sayı (`-l`) nəzərə alınmır.

## 💥 Nə baş verir

1. `lvs` yeni ölçünü göstərir, amma `df -h` köhnəsini. Task alınmır.
2. LV səhv ölçüdə olur. `lvextend` daha kiçik ölçünü qəbul etmir, amma səhv rəqəmlə `lvresize`
   LV-ni **kiçildir** və məlumatı məhv edə bilər.
3. **XFS kiçildilə bilmir.** Yeganə yol: backup, yenidən yaratmaq, bərpa etmək.
4. 16 MiB tələb olunduğu halda VG 4 MiB extent-lə yaradılır. Bunu sonradan dəyişmək olmur.

## ✅ Düzgün yol

```bash
# yaratmaq
pvcreate /dev/sdb1
vgcreate -s 16M vg_data /dev/sdb1          # task tələb edirsə extent size
lvcreate -n lv_data -l 50 vg_data           # 50 extent = burada 800 MiB
lvcreate -n lv_web  -L 500M vg_data         # və ya ölçü ilə
mkfs.xfs /dev/vg_data/lv_data

# LV-ni VƏ file system-i bir addımda böyütmək
lvextend -r -L +300M /dev/vg_data/lv_data   # -r = fs-i də böyüt
```

Artıq `-r` olmadan böyütmüsənsə:

```bash
xfs_growfs /data                 # XFS: MOUNT POINT qəbul edir
resize2fs /dev/vg_data/lv_web    # ext4: DEVICE qəbul edir
```

## 🔍 Yoxla

```bash
vgdisplay vg_data | grep "PE Size"
lvs --units m vg_data
df -h /data                      # file system ölçüsü uyğun olmalıdır
```

## 💡 Qeydlər

- İmtahanda ölçülər adətən kiçik aralığa icazə verir. Nə aldığını `lvs --units m` ilə yoxla, təxmin etmə.
- VG kiçikdirsə, `vgextend` ilə PV əlavə et. VG-ni yenidən yaratma.
