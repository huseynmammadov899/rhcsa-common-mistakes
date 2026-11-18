**English** | [Azərbaycanca](az/03-fstab.md)

# 3. /etc/fstab

## ❌ The mistake

A typo in a UUID, a wrong file system type, or a missing field. The student never tests the
file and goes straight to reboot.

## 💥 What happens

On boot systemd can't mount the entry and the system drops into **emergency mode**. One bad line
breaks the whole machine, including tasks that were already finished.

## ✅ The right way

```bash
blkid /dev/vg_data/lv_data          # copy the UUID, don't retype it
mkdir -p /data
vim /etc/fstab
```

```
UUID=3f2a...-...   /data   xfs    defaults   0 0
UUID=9c1b...-...   none    swap   defaults   0 0
```

Then **test without rebooting**:

```bash
systemctl daemon-reload
findmnt --verify        # syntax and existence check for every line
mount -a                # mounts everything that isn't mounted yet; errors show here
swapon -a
```

## 🔍 Verify

```bash
findmnt /data
swapon --show
df -hT /data
```

## 💡 Notes

- Use **UUID** (or `/dev/mapper/...` for LVM), not `/dev/sdb1`. Device names can change between boots.
- `mount -a` only proves the mount works. If the line is wrong but the file system is already mounted,
  `mount -a` stays silent. `findmnt --verify` catches that case.
- If you end up in emergency mode: log in as root, `mount -o remount,rw /`, fix `/etc/fstab`,
  `systemctl daemon-reload`, then reboot.
