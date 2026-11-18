[English](../06-users-groups.md) | **Azərbaycanca**

# 6. User və group-lar

## ❌ Səhvlər

1. Group əlavə etmək üçün `usermod -G sysadmin natasha`.
2. **İnteraktiv shell-i olmamalı** user-ə `/bin/false` verilir, heç nə verilmir, ya da shell bash olaraq qalır.
3. Konkret UID tələb olunur, amma user `-u` olmadan yaradılır.
4. Parol müddəti `/etc/shadow` əllə redaktə edilərək təyin olunur, ya da yalnız bir user nəzərdə tutulduğu halda `/etc/login.defs` dəyişdirilir.

## 💥 Nə baş verir

1. `-a` olmadan `-G` bütün əlavə group-ları **əvəz edir**. User digər bütün group-larını səssizcə itirir.
2. Task adətən `nologin` deyir və yoxlama dəqiq shell-ə baxır.
3. UID yoxlaması uğursuz olur və user-in faylları səhv rəqəmli sahibliklə qala bilər.
4. Əllə redaktə edilmiş `/etc/shadow` asanlıqla korlanır. `login.defs` isə yalnız **yeni** user-lərə təsir edir.

## ✅ Düzgün yol

```bash
groupadd sysadmin
useradd -G sysadmin natasha                   # əlavə group ilə yeni user
usermod -aG sysadmin harry                    # mövcud user: -a = APPEND (əlavə et)
useradd -s /sbin/nologin sarah                # interaktiv login yoxdur
useradd -u 3533 alex                          # konkret UID
echo 'password' | passwd --stdin natasha      # parolu interaktiv olmadan təyin et

chage -M 90 natasha                           # bir user üçün maksimum parol müddəti
chage -d 0 natasha                            # növbəti login-də dəyişməyə məcbur et
# BÜTÜN yeni user-lər üçün: /etc/login.defs-də PASS_MAX_DAYS
```

## 🔍 Yoxla

```bash
id natasha
getent passwd sarah          # son sahə: /sbin/nologin
chage -l natasha
```

## 💡 Qeydlər

- `sudo` hüquqları: faylı `/etc/sudoers.d/` içinə qoy və `visudo -f` ilə redaktə et. sudoers-də
  sintaksis xətası səni sudo-dan kəsə bilər.
- Group əsaslı sudo: `%sysadmin ALL=(ALL) ALL`.
