**English** | [Azərbaycanca](README.az.md)

# RHCSA: The 10 Mistakes Students Make Most Often

I mentor RHCSA (EX200) candidates and review their hands-on tasks. The same mistakes keep coming
back, and most of them aren't about knowledge. The task *looked* done, but it **didn't survive a
reboot**, or it **broke something else**.

This repo collects those mistakes. Each one has:

- ❌ **the mistake**: what students typically do
- 💥 **what happens**: why it fails, often only after a reboot
- ✅ **the right way**: commands that work on RHEL 9
- 🔍 **verify**: how to prove it's done before moving on

There is also a read-only [`rhcsa-sanity-check.sh`](scripts/rhcsa-sanity-check.sh) that you can run
on a practice VM to find *"works now, gone after reboot"* problems.

> Based on the **public** EX200 objectives and my own mentoring experience. It contains no exam
> questions. Red Hat exams are under NDA, and this repo respects that.

---

## The list

| # | Topic | The mistake in one line |
|---|-------|-------------------------|
| 1 | [Root password reset](mistakes/01-root-password-reset.md) | Forgetting `/.autorelabel` (or typing `./autorelabel`) → nobody can log in |
| 2 | [Persistence](mistakes/02-persistence.md) | `start` without `enable`, runtime-only changes |
| 3 | [/etc/fstab](mistakes/03-fstab.md) | A typo that drops the system into emergency mode |
| 4 | [LVM resizing](mistakes/04-lvm.md) | Growing the LV but not the file system |
| 5 | [SELinux contexts](mistakes/05-selinux.md) | `chcon` instead of `semanage fcontext` |
| 6 | [Users and groups](mistakes/06-users-groups.md) | `usermod -G` silently removes other groups |
| 7 | [Shared directories](mistakes/07-shared-directories.md) | Missing setgid bit and default ACLs |
| 8 | [Firewall + SELinux ports](mistakes/08-firewall-ports.md) | Opening the port in only one of the two |
| 9 | [Networking with nmcli](mistakes/09-networking.md) | Address set, but method still `auto` |
| 10 | [Rootless containers as services](mistakes/10-rootless-containers.md) | `su -` to the user and no linger |

Plus [exam-day habits](mistakes/exam-habits.md) that prevent most of these.

---

## The sanity check script

Run it on your **practice** VM before you reboot:

```bash
sudo ./scripts/rhcsa-sanity-check.sh
```

It only reads. It changes nothing and reports:

- `/etc/fstab` errors and entries that aren't mounted
- services that are **running now but disabled** (gone after reboot)
- firewall rules that exist only at **runtime** or only in the **permanent** config
- SELinux mode: current vs. the config file
- files whose SELinux label differs from policy (a typical leftover of `chcon`)
- swap in fstab vs. swap that is actually active
- network connections that won't come up at boot

## Practice

Reading isn't enough. For each mistake, **make it on purpose** on a practice VM, reboot, watch it
break, then fix it the right way. After that you won't make it in the exam.

## Author

**Huseyn Mammadov**, Linux/DevOps Engineer, RHCSA, and RHCSA & DevOps mentor.
[LinkedIn](https://www.linkedin.com/in/huseynmemmedov/) · [Credly](https://www.credly.com/users/hsmammadov/)

## License

MIT
