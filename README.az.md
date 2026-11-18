[English](README.md) | **Azərbaycanca**

# RHCSA: tələbələrin ən çox etdiyi 10 səhv

RHCSA (EX200) namizədlərinə mentorluq edirəm və onların praktiki task-larını yoxlayıram. Eyni
səhvlər təkrar-təkrar qarşıma çıxır və onların çoxu bilik çatışmazlığından deyil. Task *bitmiş
görünürdü*, amma ya **reboot-dan sonra itdi**, ya da **başqa bir şeyi sındırdı**.

Bu repo həmin səhvləri bir yerə toplayır. Hər birində bunlar var:

- ❌ **səhv**: tələbələrin adətən etdiyi
- 💥 **nə baş verir**: niyə alınmır, çox vaxt yalnız reboot-dan sonra
- ✅ **düzgün yol**: RHEL 9-da işləyən komandalar
- 🔍 **yoxla**: növbəti task-a keçməzdən əvvəl işin bitdiyini necə sübut etmək

Bundan əlavə, heç nəyi dəyişməyən [`rhcsa-sanity-check.sh`](scripts/rhcsa-sanity-check.sh) skripti
var. Onu təcrübə VM-ində işlədib *"indi işləyir, reboot-dan sonra yoxdur"* problemlərini tapa bilərsən.

> Bu material EX200-ün **public** mövzu siyahısına və mənim mentorluq təcrübəmə əsaslanır.
> İçində imtahan sualı yoxdur. Red Hat imtahanları NDA altındadır və bu repo buna hörmət edir.

---

## Siyahı

| # | Mövzu | Bir sətirdə səhv |
|---|-------|------------------|
| 1 | [Root parolunun bərpası](mistakes/az/01-root-password-reset.md) | SELinux relabel unudulur → heç kim login ola bilmir |
| 2 | [Persistence](mistakes/az/02-persistence.md) | `enable` olmadan `start`, yalnız runtime dəyişikliklər |
| 3 | [/etc/fstab](mistakes/az/03-fstab.md) | Bir hərf səhvi sistemi emergency mode-a salır |
| 4 | [LVM ölçüsünün dəyişməsi](mistakes/az/04-lvm.md) | LV böyüyür, file system yox |
| 5 | [SELinux context-ləri](mistakes/az/05-selinux.md) | `semanage fcontext` yerinə `chcon` |
| 6 | [User və group-lar](mistakes/az/06-users-groups.md) | `usermod -G` digər group-ları səssizcə silir |
| 7 | [Ortaq qovluqlar](mistakes/az/07-shared-directories.md) | setgid bit-i və default ACL yoxdur |
| 8 | [Firewall + SELinux port-ları](mistakes/az/08-firewall-ports.md) | Port ikisindən yalnız birində açılır |
| 9 | [nmcli ilə şəbəkə](mistakes/az/09-networking.md) | Ünvan yazılıb, amma method hələ də `auto` |
| 10 | [Service kimi rootless container-lər](mistakes/az/10-rootless-containers.md) | User-ə `su -` ilə keçid və linger yoxdur |

Üstəlik, bu səhvlərin çoxunun qarşısını alan [imtahan günü vərdişləri](mistakes/az/exam-habits.md).

---

## Sanity check skripti

Onu **təcrübə** VM-ində, reboot-dan əvvəl işə sal:

```bash
sudo ./scripts/rhcsa-sanity-check.sh
```

Skript yalnız oxuyur, heç nəyi dəyişmir və bunları göstərir:

- `/etc/fstab`-dakı xətalar və mount olunmamış sətirlər
- **indi işləyən, amma disable olan** servislər (reboot-dan sonra işə düşməyəcək)
- yalnız **runtime**-da və ya yalnız **permanent** konfiqdə olan firewall qaydaları
- SELinux rejimi: hazırkı vəziyyət və konfiq faylı
- SELinux label-i policy-dən fərqlənən fayllar (adətən `chcon`-dan qalır)
- fstab-dakı swap və həqiqətən aktiv olan swap
- boot zamanı qalxmayacaq şəbəkə bağlantıları

## Təcrübə

Oxumaq kifayət deyil. Hər səhvi təcrübə VM-ində **qəsdən et**, reboot et, necə sındığına bax,
sonra düzgün yolla düzəlt. Ondan sonra imtahanda o səhvi etməyəcəksən.

## Müəllif

**Hüseyn Məmmədov**, Linux/DevOps Engineer, RHCSA, RHCSA və DevOps mentoru.
[LinkedIn](https://www.linkedin.com/in/huseynmemmedov/) · [Credly](https://www.credly.com/users/hsmammadov/)

## Lisenziya

MIT
