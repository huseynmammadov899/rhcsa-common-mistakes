[English](../exam-habits.md) | **Azərbaycanca**

# İmtahan günü vərdişləri

Yoxladığım uğursuz task-ların çoxu bilik çatışmazlığından deyildi. Bu vərdişlər o boşluğu bağlayır.

1. **Əvvəlcə bütün imtahanı oxu.** Bəzi task-lar digərlərindən asılıdır: ortaq qovluqlardan əvvəl
   user-lər, paket quraşdırmaqdan əvvəl repository-lər, login ola bilmirsənsə hər şeydən əvvəl root parolu.
2. **Hər task-ı bitirən kimi yoxla.** Bu repodakı hər səhifənin 🔍 komandalarından istifadə et.
   "Xəta mesajı yoxdur" "bitib" demək deyil.
3. **Özün iki dəfə reboot et**: bir dəfə ortada, bir dəfə ~30 dəqiqə qalmış. Sonra hər şeyi yenidən
   yoxla. Qiymətləndirmə də reboot edir.
4. **Kopyala, yenidən yazma.** UUID-lər, image adları, uzun path-lər: copy-paste və ya
   `$(blkid -s UUID -o value ...)` istifadə et.
5. **`man` və `--help`-dən istifadə et.** İcazəlidir və sürətlidir:
   `man semanage-fcontext`-də dəqiq `"/dir(/.*)?"` nümunəsi var, `man 5 fstab`-da sahələr.
6. **Nəyisə işlətmək üçün heç vaxt SELinux-u və ya firewall-u söndürmə.** Əsl səbəbi tap.
7. **İlişib qalma.** Task 15 dəqiqədən çox çəkirsə, qeyd et və sonra qayıt.
8. **Dəyişdiklərinin qeydini saxla.** Reboot nəyisə sındırsa, hara baxacağını biləcəksən.
