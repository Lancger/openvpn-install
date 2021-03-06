## 一、安装openvpn
```bash
OpenVPN在Ubuntu的默认仓库中是可用的，所以我们可用使用apt来安装。我们还需安装一个easy-rsa包，这个包可以帮助我们建立一个内部CA（certificate authority）用于使用我们VPN。

$ sudo apt-get update
$ sudo apt-get install openvpn easy-rsa
$ sudo apt-get install libssl-dev openssl

上述命令执行完成后，会有一个/etc/openvpn的目录，通常我们把配置文件都放在这个目录下。
```

2.复制服务端配置文件到配置文件目录
```
开始之前，我们可以使用make-cadir命令，用于复制easy-rsa临时目录到我们的home目录下面：
$ sudo make-cadir /etc/openvpn/easy-rsa/

上面这条命令也用下面的两条命令来做：
$ mkdir /etc/openvpn/easy-rsa/
$ cp -r /usr/share/easy-rsa/*  /etc/openvpn/easy-rsa/
```

## 二、服务器证书ca.crt

首先进入到我们新创建的目录中来开始配置CA

1.ca证书制作
```
$ cd /etc/openvpn/easy-rsa/
$ vim /etc/openvpn/easy-rsa/vars    #修改证书的相关配置，根据需要自定义，也可以忽略不设置

export KEY_COUNTRY="CN"
export KEY_PROVINCE="GD"
export KEY_CITY="ShanTou City"
export KEY_ORG="STU"
export KEY_EMAIL="test@163.com"
export KEY_OU="University"
到这步之后，我们再编辑KEY_NAME的值，简单起见，我们将它命名为vpn_server，如下：
export KEY_NAME="server"

$ source vars
$ ./clean-all

生成根证书
$ ./build-ca

执行报错
root@openvpn:/etc/openvpn/easy-rsa# ./build-ca
grep: /etc/openvpn/easy-rsa/openssl.cnf: No such file or directory
pkitool: KEY_CONFIG (set by the ./vars script) is pointing to the wrong
version of openssl.cnf: /etc/openvpn/easy-rsa/openssl.cnf
The correct version should have a comment that says: easy-rsa version 2.x
root@openvpn:/etc/openvpn/easy-rsa#

报错解决
cd /etc/openvpn/easy-rsa/
ln -s openssl-1.0.0.cnf openssl.cnf
```

## 三、服务端证书server.crt

1.制作证书
```
$ ./build-key-server server

$ ./build-dh

$ openvpn --genkey --secret keys/ta.key
```

## 四、客户端证书

1.创建客户端证书
```
$ ./build-key client1

```

## 五、修改配置文件
1.服务器端证书和密钥统一放到和server.conf一个目录下，便于配置
```
cd cd /etc/openvpn/easy-rsa/keys/

sudo cp ca.crt server.crt server.key ta.key dh2048.pem /etc/openvpn
```
2.修改openvpn服务端配置文件server.conf
```
cat /etc/openvpn/server.conf

local 0.0.0.0
port 1194                #指定端口
proto tcp                #指定协议
dev tun                  #采用路由隧道模式
ca ca.crt                #ca证书位置，相对路径，表示ca.crt和server.conf要在同一目录
cert server.crt      #服务端证书
key server.key       #服务端key
dh dh2048.pem                #dh密钥
server 10.8.0.0 255.255.255.0        #给客户端分配的地址池
ifconfig-pool-persist ipp.txt
push "route 172.18.71.0 255.255.255.0 vpn_gateway"    #访问172.18.71.0/24网段走vpn网关,其他的走默认网关
client-to-client  # 可以让客户端之间相互访问直接通过openvpn程序转发，根据需要设置
duplicate-cn  # 如果客户端都使用相同的证书和密钥连接VPN，一定要打开这个选项，否则每个证书只允许一个人连接VPN
#push "redirect-gateway def1 bypass-dhcp"             #客户端网关使用openvpn服务器网关
#push "dhcp-option DNS 8.8.8.8"                       #指定dns
#push "dhcp-option DNS 114.114.114.114"
keepalive 10 120              #心跳检测，10秒检测一次，2分钟内没有回应则视为断线
tls-auth ta.key 0             #服务端值为0，客户端为1
cipher AES-256-CBC
comp-lzo            #传输数据压缩
persist-key
persist-tun
status openvpn-status.log
log openvpn.log
verb 3
```
3.设置客户端使用的配置文件(在用户客户端使用)
```
yum install -y openvpn     #linux客户端安装

cat /etc/openvpn/client1.ovpn

client
dev tun
proto tcp                  #和server端一致
remote 120.79.153.251 1194   #指定服务端IP和端口
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
ca ca.crt              #ca证书
cert client1.crt      #客户端证书
key client1.key       #客户端密钥
tls-auth ta.key 1      #ta密钥
cipher AES-256-CBC
comp-lzo               #传输内容压缩
verb 3                 #日志级别
```
4.客户端所需证书(下载保存到客户端和客户端配置文件同一目录下)
```
/etc/openvpn/easy-rsa/keys/client1.crt     
/etc/openvpn/easy-rsa/keys/client1.key   
/etc/openvpn/easy-rsa/keys/ca.crt  
/etc/openvpn/easy-rsa/keys/ta.key
```

## 六、服务启动
```
#server服务器端
sudo systemctl restart openvpn@server

sudo systemctl status openvpn@server

sudo systemctl enable openvpn@server

#linux客户端
openvpn --daemon --cd /etc/openvpn --config client.ovpn --log-append /var/log/openvpn.log   #放后台执行  
```

## 七、防火墙设置

1.开启内核转发
```
临时生效：
echo "1" > /proc/sys/net/ipv4/ip_forward

永久生效的话，需要修改sysctl.conf
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf

已存在替换
sed -i 's#net.ipv4.ip_forward = 0#net.ipv4.ip_forward = 1#' /etc/sysctl.conf

立即生效
sysctl -p

```
2.查看路由
```
sudo ip route | grep default

default via 172.18.79.253 dev eth0 proto dhcp src 172.18.71.139 metric 100

sudo vim /etc/ufw/before.rules

新增下面nat配置(加到最后ufw-before-forward和filter之间)
#   ufw-before-forward

....
# START OPENVPN RULES
# NAT table rules
*nat
:POSTROUTING ACCEPT [0:0] 
# Allow traffic from OpenVPN client to wlp11s0 (change to the interface you discovered!)
-A POSTROUTING -s 10.8.0.0/8 -o eth0 -j MASQUERADE
#-A POSTROUTING -o eth0 -j MASQUERADE
COMMIT
# END OPENVPN RULES
...

# Don't delete these required lines, otherwise there will be errors
*filter

sudo vim /etc/default/ufw

允许转发流量通过
DEFAULT_FORWARD_POLICY="ACCEPT"

sudo ufw allow 1194/udp
sudo ufw allow OpenSSH

sudo ufw disable
sudo ufw enable
sudo ufw status

设置nat转发:
注：保证VPN地址池可路由出外网(避免拨了vpn上不了外网的情况)
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE

永久保存：
iptables-save > /etc/sysconfig/iptables
或
/etc/init.d/iptables save

#查看防火墙nat策略
iptables -t nat -L -n

```
参考资料：

https://www.digitalocean.com/community/tutorials/how-to-set-up-an-openvpn-server-on-ubuntu-16-04

https://help.ubuntu.com/community/OpenVPN
