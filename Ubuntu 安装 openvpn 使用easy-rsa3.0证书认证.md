## 一、安装openvpn
```bash
OpenVPN在Ubuntu的默认仓库中是可用的，所以我们可用使用apt来安装。我们还需安装一个easy-rsa包，这个包可以帮助我们建立一个内部CA（certificate authority）用于使用我们VPN。

$ sudo apt-get update
$ sudo apt-get install openvpn easy-rsa
$ sudo apt-get install bridge-utils libssl-dev openssl

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

首先进入到我们新创建的目录中来开始配置CA：
1.ca证书制作
```
$ cd ~/openvpn-ca
$ vim ~/openvpn-ca/vars    #修改证书的相关配置，根据需要自定义，也可以忽略不设置

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
```

## 三、服务端证书server.crt

1.制作证书
```
[root@openvpn easy-rsa]# ./easyrsa gen-req vpn_server nopass  #nopass设置免证书密码，如果要设置密码可以取消此参数选项

Note: using Easy-RSA configuration from: ./vars   #使用vars文件里面配置的信息
Generating a 2048 bit RSA private key
..+++
..........+++
writing new private key to '/etc/openvpn/easy-rsa/pki/private/vpn_server.key.Wednp5WSPr'
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Common Name (eg: your user, host, or server name) [vpn_server]:  #直接回车，默认名字为vpn_server

Keypair and certificate request completed. Your files are:
req: /etc/openvpn/easy-rsa/pki/reqs/vpn_server.req
key: /etc/openvpn/easy-rsa/pki/private/vpn_server.key   #密钥key的路径
```
2.证书签名、签约
```
[root@openvpn easy-rsa]# ./easyrsa sign server vpn_server   #vpn_server根据上面证书名保持一致

Note: using Easy-RSA configuration from: ./vars


You are about to sign the following certificate.
Please check over the details shown below for accuracy. Note that this request
has not been cryptographically verified. Please be sure it came from a trusted
source or that you have verified the request checksum with the sender.

Request subject, to be signed as a server certificate for 3650 days:

subject=
    commonName                = vpn_server


Type the word 'yes' to continue, or any other input to abort.
  Confirm request details: yes
Using configuration from ./openssl-1.0.cnf
Enter pass phrase for /etc/openvpn/easy-rsa/pki/private/ca.key:     123456       #输入上面ca证书生成时的密码（123456）
Check that the request matches the signature
Signature ok
The Subject's Distinguished Name is as follows
commonName            :PRINTABLE:'vpn_server'
Certificate is to be certified until May 22 03:23:38 2028 GMT (3650 days)

Write out database with 1 new entries
Data Base Updated

Certificate created at: /etc/openvpn/easy-rsa/pki/issued/vpn_server.crt          #服务端证书路径
```

3.dh证书
```
[root@openvpn easy-rsa]# ./easyrsa gen-dh     #创建Diffie-Hellman，时间有点长
Note: using Easy-RSA configuration from: ./vars
Generating DH parameters, 2048 bit long safe prime, generator 2
This is going to take a long time
........................................++*++*

DH parameters of size 2048 created at /etc/openvpn/pki/dh.pem      #dh证书路径
```

4.ta密钥
```
[root@openvpn easy-rsa]# cd /etc/openvpn
[root@openvpn openvpn]# openvpn --genkey --secret ta.key
```

## 四、客户端证书

为了便于区别，我们把客户端使用的证书存放在新的路径。/etc/openvpn/client

1.创建客户端证书
```
[root@openvpn client]# mkdir -p /etc/openvpn/client
[root@openvpn client]# cd /etc/openvpn/client
[root@openvpn client]# cp -r /etc/openvpn/easy-rsa/* /etc/openvpn/client/
[root@openvpn client]# ./easyrsa init-pki
[root@openvpn client]# ./easyrsa gen-req client01 nopass   #client01为证书名，可自定义，nopass同样设置免密

Note: using Easy-RSA configuration from: ./vars
Generating a 2048 bit RSA private key
....+++
....................+++
writing new private key to '/etc/openvpn/client/pki/private/client01.key.wDFG7wJLuL'
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Common Name (eg: your user, host, or server name) [client01]:

Keypair and certificate request completed. Your files are:
req: /etc/openvpn/client/pki/reqs/client01.req
key: /etc/openvpn/client/pki/private/client01.key   #key路径

```

2.对客户端证书签名、签约
```
#切换到服务端easy-rsa目录下：
[root@openvpn client]# cd /etc/openvpn/easy-rsa
#导入req
[root@openvpn easy-rsa]# ./easyrsa import-req /etc/openvpn/client/pki/reqs/client01.req client01

[root@openvpn easy-rsa]# ./easyrsa sign client client01
Note: using Easy-RSA configuration from: ./vars


You are about to sign the following certificate.
Please check over the details shown below for accuracy. Note that this request
has not been cryptographically verified. Please be sure it came from a trusted
source or that you have verified the request checksum with the sender.

Request subject, to be signed as a client certificate for 3650 days:

subject=
    commonName                = client01


Type the word 'yes' to continue, or any other input to abort.
  Confirm request details: yes                                    #输入'yes'
Using configuration from ./openssl-1.0.cnf
Enter pass phrase for /etc/openvpn/easy-rsa/pki/private/ca.key:   #输入ca密码（123456）
Check that the request matches the signature
Signature ok
The Subject's Distinguished Name is as follows
commonName            :PRINTABLE:'client01'
Certificate is to be certified until Apr 13 14:37:17 2028 GMT (3650 days)

Write out database with 1 new entries
Data Base Updated

Certificate created at: /etc/openvpn/easy-rsa/pki/issued/client01.crt     #最终客户端证书路径

```

## 五、修改配置文件
1.服务器端证书和密钥统一放到和server.conf一个目录下，便于配置
```
cp /etc/openvpn/easy-rsa/pki/ca.crt /etc/openvpn/
cp /etc/openvpn/easy-rsa/pki/private/vpn_server.key /etc/openvpn/
cp /etc/openvpn/easy-rsa/pki/issued/vpn_server.crt /etc/openvpn/
cp /etc/openvpn/easy-rsa/pki/dh.pem /etc/openvpn/
```
2.修改openvpn服务端配置文件server.conf
```
cat /etc/openvpn/server.conf

local 0.0.0.0
port 1194                #指定端口
proto tcp                #指定协议
dev tun                  #采用路由隧道模式
ca ca.crt                #ca证书位置，相对路径，表示ca.crt和server.conf要在同一目录
cert vpn_server.crt      #服务端证书
key vpn_server.key       #服务端key
dh dh.pem                #dh密钥
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

cp /usr/share/doc/openvpn-2.4.6/sample/sample-config-files/client.conf /etc/openvpn/client.ovpn

cat /etc/openvpn/client.ovpn

client
dev tun
proto tcp                  #和server端一致
remote 47.106.242.1 1194   #指定服务端IP和端口
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
ca ca.crt              #ca证书
cert client01.crt      #客户端证书
key client01.key       #客户端密钥
tls-auth ta.key 1      #ta密钥
cipher AES-256-CBC
comp-lzo               #传输内容压缩
verb 3                 #日志级别
```
4.客户端所需证书(下载保存到客户端和客户端配置文件同一目录下)
```
/etc/openvpn/easy-rsa/pki/issued/client01.crt    #在服务端证书生成目录下
/etc/openvpn/client/pki/private/client01.key     #上面的客户端生成目录下
/etc/openvpn/easy-rsa/pki/ca.crt                 #ca证书
/etc/openvpn/ta.key
```

## 六、服务启动
```
#server服务器端
service openvpn restart

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

设置nat转发:
注：保证VPN地址池可路由出外网(避免拨了vpn上不了外网的情况)
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE

永久保存：
iptables-save > /etc/sysconfig/iptables
或
/etc/init.d/iptables save

#查看防火墙nat策略
iptables -t nat -L -n

修改配置文件方式
[root@localhost]# cat /etc/sysconfig/iptables               
# Generated by iptables-save v1.4.7 on Tue Dec 26 16:39:36 2017
*filter
:INPUT ACCEPT [1707:292253]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [1615:1130954]
-A FORWARD -i tun+ -j ACCEPT 
COMMIT
# Completed on Tue Dec 26 16:39:36 2017
# Generated by iptables-save v1.4.7 on Tue Dec 26 16:39:36 2017
*nat
:PREROUTING ACCEPT [28:3113]
:POSTROUTING ACCEPT [16:960]
:OUTPUT ACCEPT [22:1365]
-A POSTROUTING -o eth0 -j MASQUERADE 
COMMIT

#iptables -t nat -L -n
[root@localhost]# iptables -t nat -L -n
Chain PREROUTING (policy ACCEPT)
target     prot opt source               destination         

Chain POSTROUTING (policy ACCEPT)
target     prot opt source               destination         
MASQUERADE  all  --  0.0.0.0/0            0.0.0.0/0           

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination 
```
参考资料：

http://www.89cool.com/807.html
