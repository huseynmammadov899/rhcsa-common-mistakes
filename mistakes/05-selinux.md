**English** | [Azərbaycanca](az/05-selinux.md)

# 5. SELinux contexts

## ❌ The mistake

Apache is told to serve `/web`, it returns `403 Forbidden`, and the student runs:

```bash
chcon -R -t httpd_sys_content_t /web
```

It works, so they move on. Even worse: `setenforce 0`.

## 💥 What happens

`chcon` changes the label on disk, but **not the policy**. The next relabel puts the old label
back, and a relabel happens, for example, after the root password reset (`/.autorelabel`, see [#1](01-root-password-reset.md)).
The web page breaks again after reboot. `setenforce 0` is a straight fail: SELinux must be enforcing.

## ✅ The right way

```bash
semanage fcontext -a -t httpd_sys_content_t "/web(/.*)?"   # write the rule into policy
restorecon -Rv /web                                         # apply it
```

Other SELinux tools you'll need:

```bash
semanage port -a -t http_port_t -p tcp 82    # non-standard port for a service (see #8)
setsebool -P httpd_enable_homedirs on        # boolean, -P = persistent
```

## 🔍 Find out what SELinux is blocking

```bash
ausearch -m AVC -ts recent
journalctl -t setroubleshoot        # if setroubleshoot-server is installed; suggests the fix
```

## 🔍 Verify

```bash
ls -Zd /web
semanage fcontext -l | grep '^/web'
matchpathcon /web                   # what policy says the label should be
restorecon -Rnv /web                # -n = dry run; empty output means everything matches
```

## 💡 Notes

- Copy the label from a known-good path: `semanage fcontext -a -e /var/www /web` (equivalence rule).
- `mv` keeps the old label, `cp` takes the destination's label. A file moved from `/root` into
  `/var/www/html` keeps `admin_home_t` and Apache can't read it.
