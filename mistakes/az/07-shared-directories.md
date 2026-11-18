[English](../07-shared-directories.md) | **Azərbaycanca**

# 7. Ortaq (collaborative) qovluqlar

Tipik task: *"`/common/admin` qovluğunu yarat, sahibi `sysadmin` group-u olsun. Üzvlər oxuyub
yaza bilsin, digərlərinin girişi olmasın. Yeni fayllar `sysadmin`-ə aid olsun."*

## ❌ Səhvlər

1. **setgid** bit-i olmadan `chmod 770`.
2. `chmod g+s` qovluğa yox, fayllara tətbiq olunur, ya da hər şeyə `chmod -R 2770` edilir.
3. "X user-i yeni fayllarda həmişə rwx almalıdır" tələbi üçün **default** ACL yox, yalnız adi ACL qoyulur.

## 💥 Nə baş verir

1. Yeni fayllar yaradanın əsas group-unu alır, ona görə digər üzvlər onları redaktə edə bilmir.
2. Fayllardakı setgid gözlənilən işi görmür, rekursiv chmod isə bütün faylları icra oluna bilən edir.
3. Adi ACL yalnız artıq mövcud olan fayllara aiddir. Sonradan yaradılan fayllar onu almır.

## ✅ Düzgün yol

```bash
mkdir -p /common/admin
chgrp sysadmin /common/admin
chmod 2770 /common/admin            # 2 = qovluqda setgid
```

ACL nümunəsi: `alex` user-i mövcud **və** gələcək fayllarda `rwx` alır:

```bash
setfacl -m u:alex:rwx /common/admin          # mövcud qovluq
setfacl -m d:u:alex:rwx /common/admin        # default ACL → yeni fayllar miras alır
```

Sticky bit (user-lər yalnız öz fayllarını silə bilər, `/tmp`-dəki kimi):

```bash
chmod 1777 /shared     # və ya 3770 = setgid + sticky
```

## 🔍 Yoxla

```bash
ls -ld /common/admin                 # drwxrws---  → "s" setgid-dir
getfacl /common/admin                # default:user:alex:rwx axtar
su - natasha -c 'touch /common/admin/t && ls -l /common/admin/t'   # group sysadmin olmalıdır
```

## 💡 Qeydlər

- ACL mask-ı (`mask::`) təyin etdiyindən dardırsa, effektiv icazələr kəsilir.
  `getfacl` sətrin yanında `#effective:` göstərir.
