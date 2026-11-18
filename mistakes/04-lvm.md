**English** | [Azərbaycanca](az/04-lvm.md)

# 4. LVM resizing

## ❌ The mistakes

1. `lvextend -L +500M /dev/vg/lv`, without growing the file system.
2. `-L 500M` (set the size **to** 500M) vs. `-L +500M` (**add** 500M) mixed up.
3. Trying to shrink an XFS file system.
4. Ignoring the requested **extent size** or an extent count (`-l`) given in the task.

## 💥 What happens

1. `lvs` shows the new size, but `df -h` still shows the old one. The task fails.
2. The LV ends up the wrong size. `lvextend` refuses a smaller target, but `lvresize` with the wrong
   number **shrinks** the LV and can destroy data.
3. **XFS cannot shrink.** The only way is backup, recreate, restore.
4. The VG is created with 4 MiB extents when 16 MiB were required. It can't be changed later.

## ✅ The right way

```bash
# create
pvcreate /dev/sdb1
vgcreate -s 16M vg_data /dev/sdb1          # extent size, if the task asks for it
lvcreate -n lv_data -l 50 vg_data           # 50 extents = 800 MiB here
lvcreate -n lv_web  -L 500M vg_data         # or a size
mkfs.xfs /dev/vg_data/lv_data

# extend LV AND file system in one step
lvextend -r -L +300M /dev/vg_data/lv_data   # -r = resize the fs too
```

If you already extended without `-r`:

```bash
xfs_growfs /data                 # XFS: takes the MOUNT POINT
resize2fs /dev/vg_data/lv_web    # ext4: takes the DEVICE
```

## 🔍 Verify

```bash
vgdisplay vg_data | grep "PE Size"
lvs --units m vg_data
df -h /data                      # file system size must match
```

## 💡 Notes

- Exam sizes usually allow a small range. Check what you got with `lvs --units m`. Don't guess.
- If the VG is too small, add a PV with `vgextend`. Don't recreate the VG.
