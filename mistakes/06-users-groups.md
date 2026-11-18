**English** | [Azərbaycanca](az/06-users-groups.md)

# 6. Users and groups

## ❌ The mistakes

1. `usermod -G sysadmin natasha` to add a group.
2. A user who must have **no interactive shell** is given `/bin/false` or nothing at all, or the shell is left as bash.
3. A specific UID is required, and the user is created without `-u`.
4. Password aging is set by editing `/etc/shadow` by hand, or by changing `/etc/login.defs` when only one user was meant.

## 💥 What happens

1. `-G` without `-a` **replaces** all supplementary groups. The user silently loses every other group.
2. The task usually says `nologin`. The grader checks the exact shell.
3. The UID check fails, and the files the user owns may end up with wrong numeric ownership.
4. Hand-edited `/etc/shadow` is easy to corrupt. `login.defs` only affects **new** users.

## ✅ The right way

```bash
groupadd sysadmin
useradd -G sysadmin natasha                   # new user with a supplementary group
usermod -aG sysadmin harry                    # existing user: -a = APPEND
useradd -s /sbin/nologin sarah                # no interactive login
useradd -u 3533 alex                          # specific UID
echo 'password' | passwd --stdin natasha      # set a password non-interactively

chage -M 90 natasha                           # max password age for one user
chage -d 0 natasha                            # force change at next login
# for ALL new users: PASS_MAX_DAYS in /etc/login.defs
```

## 🔍 Verify

```bash
id natasha
getent passwd sarah          # last field: /sbin/nologin
chage -l natasha
```

## 💡 Notes

- `sudo` rights: put a file in `/etc/sudoers.d/` and edit it with `visudo -f`. A syntax error in
  sudoers can lock you out of sudo.
- Group-based sudo: `%sysadmin ALL=(ALL) ALL`.
