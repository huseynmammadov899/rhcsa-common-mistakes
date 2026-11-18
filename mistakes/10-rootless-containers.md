**English** | [Azərbaycanca](az/10-rootless-containers.md)

# 10. Rootless containers as systemd services

Typical task: *"As user `athena`, run a container from image X, mount host directory Y, and make
it start automatically at boot as a systemd service."*

## ❌ The mistakes

1. Switching with `su - athena` and running `systemctl --user ...`.
2. Forgetting `loginctl enable-linger`.
3. Mounting a host directory without `:Z`.
4. Creating the service as root, so it becomes a root container, not athena's.

## 💥 What happens

1. `Failed to connect to bus: No medium found`. `su` doesn't start a user systemd session.
2. Without linger, the user's services **start only when the user logs in**. After a reboot nobody
   logs in, so the container doesn't run when grading happens.
3. SELinux blocks the container from reading the directory: `Permission denied` inside the container.
4. The task explicitly says rootless, as that user. A root container fails the check.

## ✅ The right way

```bash
# as root
loginctl enable-linger athena
mkdir -p /srv/data && chown athena: /srv/data

# log in AS the user (a real session, not su)
ssh athena@localhost
```

As `athena`:

```bash
podman login registry.example.com             # if the registry needs it
podman run -d --name web -p 8080:8080 \
  -v /srv/data:/data:Z \
  registry.example.com/web:latest

mkdir -p ~/.config/systemd/user && cd ~/.config/systemd/user
podman generate systemd --name web --files --new
podman stop web && podman rm web               # systemd will own it now (--new recreates it)

systemctl --user daemon-reload
systemctl --user enable --now container-web.service
```

> On newer RHEL 9 releases `podman generate systemd` is deprecated in favor of **Quadlet**
> (`~/.config/containers/systemd/web.container`). Learn both, and use what the exam environment supports.

## 🔍 Verify

```bash
loginctl show-user athena | grep Linger       # Linger=yes
systemctl --user is-enabled container-web     # as athena
podman ps
# the real test: reboot, then (without logging in as athena) check from root:
ps -u athena | grep conmon
```

## 💡 Notes

- If you used `su` by mistake: exit and log in again over ssh. Don't try to export variables by hand.
- Ports below 1024 need extra configuration for rootless containers. Exam tasks usually use high ports.
