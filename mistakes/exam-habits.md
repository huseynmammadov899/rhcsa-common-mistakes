**English** | [Azərbaycanca](az/exam-habits.md)

# Exam-day habits

Most failed tasks I review weren't failed for lack of knowledge. These habits close the gap.

1. **Read the whole exam first.** Some tasks depend on others: users before shared directories,
   repositories before installing packages, root password before everything if you can't log in.
2. **Verify every task right after doing it**, with the 🔍 commands from each page here. "No error
   message" doesn't mean done.
3. **Reboot twice yourself**, once in the middle and once with ~30 minutes left. Then re-check
   everything. The grader reboots too.
4. **Copy, don't retype.** UUIDs, image names, long paths: use copy-paste or `$(blkid -s UUID -o value ...)`.
5. **Use `man` and `--help`.** They're allowed and fast:
   `man semanage-fcontext` has the exact `"/dir(/.*)?"` example. `man 5 fstab` has the fields.
6. **Never disable SELinux or the firewall** to make something work. Find the real cause.
7. **Don't get stuck.** If a task takes more than 15 minutes, mark it and come back.
8. **Keep notes** of what you changed. If a reboot breaks something, you'll know where to look.
