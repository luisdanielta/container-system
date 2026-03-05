
## root-hints download
apt update && apt install curl -y
curl -o /opt/unbound/etc/unbound/root.hints https://www.internic.net/domain/named.cache