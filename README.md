## openvpn-install
OpenVPN [road warrior](http://en.wikipedia.org/wiki/Road_warrior_%28computing%29) installer for Debian, Ubuntu and CentOS.

This script will let you setup your own VPN server in no more than a minute, even if you haven't used OpenVPN before. It has been designed to be as unobtrusive and universal as possible.

### Installation
Run the script and follow the assistant:

```bash
wget https://raw.githubusercontent.com/Lancger/openvpn-install/master/openvpn-install.sh -O openvpn-install.sh && bash openvpn-install.sh

#如果需要保存itpable策略，执行下面指令
export Time=`date "+%Y%m%d%H%M%S"`
yes | cp /etc/sysconfig/iptables /etc/sysconfig/iptables_$Time
> /etc/sysconfig/iptables
service iptables save
```

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
ifconfig-pool-persist ipp.txt 0  --  后面必须加 0 才会生效,会自动在ip.txt记录不同账号的IP
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 100.100.2.136"
push "dhcp-option DNS 100.100.2.138"
keepalive 10 120
cipher AES-256-CBC
user nobody
group nobody
persist-key
auth-user-pass-verify /etc/openvpn/checkpsw.sh via-env   ---新增
username-as-common-name   ---新增
script-security 3  ---新增
persist-tun
status openvpn-status.log
verb 3
crl-verify crl.pem
```

# 通过CCD配置固定IP
```
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
#ifconfig-pool-persist ipp.txt
client-config-dir /etc/openvpn/ccd
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


<2019-07-30 17:28:18> /etc/openvpn
root># cat ccd/user01 
ifconfig-push 10.8.0.15 255.255.255.0

<2019-07-30 17:28:23> /etc/openvpn
root># cat ccd/user02 
ifconfig-push 10.8.0.5 255.255.255.0
```

# 客户端新增
```
auth-user-pass  ---新增

systemctl restart openvpn-server@server.service
```

# 固定IP
```
cd /etc/openvpn/ccd/

root># cat user01 
ifconfig-push 10.8.0.13 255.255.255.0
```
