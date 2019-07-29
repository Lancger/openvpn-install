## openvpn-install
OpenVPN [road warrior](http://en.wikipedia.org/wiki/Road_warrior_%28computing%29) installer for Debian, Ubuntu and CentOS.

This script will let you setup your own VPN server in no more than a minute, even if you haven't used OpenVPN before. It has been designed to be as unobtrusive and universal as possible.

### Installation
Run the script and follow the assistant:

`wget https://raw.githubusercontent.com/Lancger/openvpn-install/master/openvpn-install.sh -O openvpn-install.sh && bash openvpn-install.sh`

```
(demo3) ➜  ~ nc -zvu 47.100.42.111 1194       --测试udp端口连通性
found 0 associations
found 1 connections:
     1:	flags=82<CONNECTED,PREFERRED>
	outif (null)
	src 172.17.1.78 port 57214
	dst 47.100.42.111 port 1194
	rank info not available
```

Once it ends, you can run it again to add more users, remove some of them or even completely uninstall OpenVPN.

### I want to run my own VPN but don't have a server for that
You can get a little VPS from just $1/month at [VirMach](https://billing.virmach.com/aff.php?aff=4109&url=billing.virmach.com/cart.php?gid=1).

### Donations

If you want to show your appreciation, you can donate via [PayPal](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=VBAYDL34Z7J6L) or [cryptocurrency](https://pastebin.com/raw/M2JJpQpC). Thanks!


# 账号密码验证
```
cd /etc/openvpn/server
root># cat server.conf
port 1194
proto tcp
dev tun
sndbuf 0
rcvbuf 0
ca ca.crt
cert server.crt
key server.key
dh dh.pem
auth SHA512
tls-auth ta.key 0
topology subnet
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 100.100.2.136"
push "dhcp-option DNS 100.100.2.138"
keepalive 10 120
cipher AES-256-CBC
user nobody
group nobody
persist-key
auth-user-pass-verify /etc/openvpn/checkpsw.sh via-env
username-as-common-name
script-security 3
persist-tun
status openvpn-status.log
verb 3
crl-verify crl.pem
```

# 客户端新增
```
auth-user-pass
```
