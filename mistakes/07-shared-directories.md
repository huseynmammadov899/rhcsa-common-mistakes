**English** | [Azərbaycanca](az/07-shared-directories.md)

# 7. Shared (collaborative) directories

Typical task: *"Create `/common/admin`, owned by group `sysadmin`. Members can read and write,
others have no access. New files must belong to `sysadmin`."*

## ❌ The mistakes

1. `chmod 770`, without the **setgid** bit.
2. `chmod g+s` applied to the files instead of the directory, or `chmod -R 2770` on everything.
3. For "user X must always get rwx on new files", only a normal ACL is set, not a **default** ACL.

## 💥 What happens

1. New files get the creator's primary group, so other members can't edit them.
2. Files with setgid don't do what's intended, and the recursive chmod makes every file executable.
3. A normal ACL applies only to files that already exist. Files created later don't get it.

## ✅ The right way

```bash
mkdir -p /common/admin
chgrp sysadmin /common/admin
chmod 2770 /common/admin            # 2 = setgid on the directory
```

ACL example: user `alex` gets `rwx` on existing **and** future files:

```bash
setfacl -m u:alex:rwx /common/admin          # existing directory
setfacl -m d:u:alex:rwx /common/admin        # default ACL → inherited by new files
```

Sticky bit (users may delete only their own files, like `/tmp`):

```bash
chmod 1777 /shared     # or 3770 = setgid + sticky
```

## 🔍 Verify

```bash
ls -ld /common/admin                 # drwxrws---  → the "s" is setgid
getfacl /common/admin                # look for default:user:alex:rwx
su - natasha -c 'touch /common/admin/t && ls -l /common/admin/t'   # group must be sysadmin
```

## 💡 Notes

- If the ACL mask (`mask::`) is narrower than what you set, effective permissions are cut.
  `getfacl` shows `#effective:` next to the entry.
