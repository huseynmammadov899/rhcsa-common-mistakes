**English** | [Azərbaycanca](az/08-firewall-ports.md)

# 8. Firewall + SELinux ports

Typical task: *"Apache must serve on port 82."*

## ❌ The mistakes

1. `Listen 82` is set in httpd.conf, but SELinux still doesn't allow httpd to bind 82, so `httpd` fails to start.
2. The SELinux port is fixed, but the firewall isn't opened, so the site works on `localhost` and not from outside.
3. The firewall is opened without `--permanent`, or with `--permanent` but no `--reload`.

## 💥 What happens

There are **two separate gates**. SELinux decides whether the *service* may use the port, the
firewall decides whether *traffic* may reach it. Fixing only one of them leaves the task failed.
Runtime vs. permanent is mistake [#2](02-persistence.md) again.

## ✅ The right way

```bash
# 1. service config
sed -i 's/^Listen 80$/Listen 82/' /etc/httpd/conf/httpd.conf

# 2. SELinux: allow httpd on 82
semanage port -l | grep http_port_t          # see what's already allowed
semanage port -a -t http_port_t -p tcp 82

# 3. firewall
firewall-cmd --permanent --add-port=82/tcp
firewall-cmd --reload

# 4. service
systemctl enable --now httpd
systemctl restart httpd                       # if it was already running
```

## 🔍 Verify

```bash
ss -ltnp | grep :82
firewall-cmd --list-ports                     # runtime
firewall-cmd --permanent --list-ports         # permanent, both must show 82/tcp
curl -s http://localhost:82 | head -3         # local
curl -s http://<server-ip>:82 | head -3       # from another machine
```

## 💡 Notes

- If httpd won't start, `journalctl -u httpd -e` shows `Permission denied: AH00072: make_sock`.
  That's the SELinux port, not a typo.
- Standard ports: use services, e.g. `--add-service=http`. Non-standard: `--add-port`.
