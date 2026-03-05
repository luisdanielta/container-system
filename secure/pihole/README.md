## This command will disable systemd-resolved
Is required to disable systemd-resolved in your machine to use the DNS server of your choice.
```bash
systemctl disable systemd-resolved.service
systemctl stop systemd-resolved
```

## docker-wildcard.conf

pihole-FTL --config misc.etc_dnsmasq_d true

```bash
sudo vi /etc/dnsmasq.d/05-docker-wildcard.conf
address=/.docker.local/10.10.3.199 # traefik
```

```bash
pihole reloaddns
```