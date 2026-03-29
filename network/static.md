```
sudo iptables -F DOCKER-USER
```

```
sudo iptables -I DOCKER-USER -i enp1s0 -s 192.168.1.0/24 -d 10.10.3.0/24 -j ACCEPT
```

```
sudo iptables -I DOCKER-USER -o enp1s0 -s 10.10.3.0/24 -d 192.168.1.0/24 -j ACCEPT
```

```
sudo iptables -A DOCKER-USER -j RETURN
```