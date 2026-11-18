**English** | [Azərbaycanca](az/01-root-password-reset.md)

# 1. Root password reset

## ❌ The mistake

The student boots with `rd.break`, changes the password, and reboots, but forgets `touch /.autorelabel`.

## 💥 What happens

`passwd` rewrites `/etc/shadow`. SELinux policy isn't loaded at that stage, so the new file gets the
wrong label. After reboot, with SELinux enforcing, the login process can't read `/etc/shadow`:
**nobody can log in, not even with the new password.** On a remote exam that means losing the machine.

## ✅ The right way (RHEL 9)

1. Reboot. In the GRUB menu, press `e` on the default entry.
2. At the end of the line starting with `linux`, add `rd.break`. Press `Ctrl+x`.
3. Then run:

```bash
mount -o remount,rw /sysroot
chroot /sysroot
passwd root
touch /.autorelabel        # ← the line people forget
exit
exit
```

The first boot after this takes longer while SELinux relabels the file system. That's expected,
**don't interrupt it**.

## ❌ The typo version of the same mistake

Students remember the step but swap the dot and the slash. The file must be called `.autorelabel`
(a hidden file) and it must be in `/` (the root of the file system):

| Typed | What it actually creates | Relabel? |
|-------|--------------------------|----------|
| `touch /.autorelabel` | `/.autorelabel` ✅ | yes |
| `touch ./autorelabel` | `autorelabel` (no dot) in the current directory | ❌ no |
| `touch /autorelabel` | `/autorelabel` (no dot) | ❌ no |
| `touch .autorelabel` | `.autorelabel` in the **current** directory, only right if you're in `/` | ⚠️ maybe |
| `touch /sysroot/.autorelabel` | correct **only before** `chroot`; inside chroot it creates `/sysroot/sysroot/...`, which fails or misses | ⚠️ |

No error message appears in any of these cases: `touch` happily creates whatever you typed. So
**check before you exit**:

```bash
ls -la /.autorelabel        # must exist, and must be exactly this path
```

Read it as "slash, then dot": `/` + `.autorelabel`.

## 🔍 Verify

```bash
ssh root@localhost          # or log in on the console with the new password
getenforce                  # should still be Enforcing
ls -Z /etc/shadow           # system_u:object_r:shadow_t:s0
```

## 💡 Notes

- Don't "fix" a login problem by setting SELinux to permissive. The exam checks that it's enforcing.
- If you're unsure the edit applied, check `cat /proc/cmdline` before running anything else.
