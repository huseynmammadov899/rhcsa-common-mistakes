**English** | [Azərbaycanca](az/09-networking.md)

# 9. Networking with nmcli

## ❌ The mistakes

1. The address is set, but `ipv4.method` is still `auto`.
2. The connection is modified, but never re-activated.
3. `ipv4.addresses` is written without a prefix (`/24`).
4. The student edits files in `/etc/NetworkManager/system-connections/` by hand and doesn't reload.

## 💥 What happens

1. The interface gets **both** a DHCP address and the static one, or the static one is ignored.
2. `nmcli con mod` only changes the saved profile. Nothing changes on the interface until `con up` or a reboot.
3. Without a prefix the result isn't what you intended.
4. NetworkManager doesn't see the change.

## ✅ The right way

```bash
nmcli con show                                   # find the CONNECTION name (not always = device name)
nmcli con mod "System eth0" \
  ipv4.addresses 192.168.10.20/24 \
  ipv4.gateway 192.168.10.1 \
  ipv4.dns 192.168.10.1 \
  ipv4.method manual \
  connection.autoconnect yes
nmcli con up "System eth0"

hostnamectl set-hostname server1.example.com
```

> ⚠️ On the exam, changing the IP of the interface you're connected through can cut your session.
> Read the task twice and type the address carefully.

## 🔍 Verify

```bash
ip -4 addr show eth0
ip route | grep default
cat /etc/resolv.conf
nmcli -g ipv4.method,connection.autoconnect con show "System eth0"
hostnamectl
```

## 💡 Notes

- `nmtui` is fine too. It's a menu over the same thing and saves typos.
- Edited the file by hand? Run `nmcli con reload`, then `nmcli con up <name>`.
