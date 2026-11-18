[English](../10-rootless-containers.md) | **Azərbaycanca**

# 10. Systemd service kimi rootless container-lər

Tipik task: *"`athena` user-i kimi X image-indən container işə sal, host-dakı Y qovluğunu mount et
və onu systemd service kimi boot zamanı avtomatik işə düşən et."*

## ❌ Səhvlər

1. `su - athena` ilə keçib `systemctl --user ...` işlətmək.
2. `loginctl enable-linger`-i unutmaq.
3. Host qovluğunu `:Z` olmadan mount etmək.
4. Service-i root kimi yaratmaq, nəticədə container athena-nın yox, root-un olur.

## 💥 Nə baş verir

1. `Failed to connect to bus: No medium found`. `su` user-in systemd sessiyasını başlatmır.
2. Linger olmadan user-in servisləri **yalnız user login olanda işə düşür**. Reboot-dan sonra heç
   kim login olmur, ona görə qiymətləndirmə zamanı container işləmir.
3. SELinux container-in qovluğu oxumasını bloklayır: container içində `Permission denied`.
4. Task açıq şəkildə həmin user kimi, rootless deyir. Root container yoxlamadan keçmir.

## ✅ Düzgün yol

```bash
# root kimi
loginctl enable-linger athena
mkdir -p /srv/data && chown athena: /srv/data

# user KİMİ login ol (su yox, real sessiya)
ssh athena@localhost
```

`athena` kimi:

```bash
podman login registry.example.com             # registry tələb edirsə
podman run -d --name web -p 8080:8080 \
  -v /srv/data:/data:Z \
  registry.example.com/web:latest

mkdir -p ~/.config/systemd/user && cd ~/.config/systemd/user
podman generate systemd --name web --files --new
podman stop web && podman rm web               # artıq onu systemd idarə edəcək (--new yenidən yaradır)

systemctl --user daemon-reload
systemctl --user enable --now container-web.service
```

> RHEL 9-un yeni buraxılışlarında `podman generate systemd` deprecated-dir, onun yerinə **Quadlet**
> tövsiyə olunur (`~/.config/containers/systemd/web.container`). Hər ikisini öyrən və imtahan
> mühitinin dəstəklədiyini istifadə et.

## 🔍 Yoxla

```bash
loginctl show-user athena | grep Linger       # Linger=yes
systemctl --user is-enabled container-web     # athena kimi
podman ps
# əsl test: reboot et, sonra (athena kimi login olmadan) root-dan yoxla:
ps -u athena | grep conmon
```

## 💡 Qeydlər

- Səhvən `su` istifadə etmisənsə: çıx və ssh ilə yenidən login ol. Dəyişənləri əllə export etməyə çalışma.
- Rootless container-lər üçün 1024-dən aşağı portlar əlavə konfiqurasiya tələb edir. İmtahan task-ları adətən yüksək portlardan istifadə edir.
