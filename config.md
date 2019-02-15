## 一、server参数详解
```
[root@localhost config]#cat server.conf
local 192.168.1.123    #指定监听的本机IP(因为有些计算机具备多个IP地址)，该命令是可选的，默认监听所有IP地址。
port 1194             #指定监听的本机端口号
;proto udp             #指定采用的传输协议，可以选择tcp或udp
proto tcp
dev tun               #指定创建的通信隧道类型，可选tun或tap
ca /usr/local/open***/config/ca.crt          #指定CA证书的文件路径
cert /usr/local/open***/config/server.crt       #指定服务器端的证书文件路径
key /usr/local/open***/config/server.key   #指定服务器端的私钥文件路径
dh /usr/local/open***/config/dh2048.pem         #指定迪菲赫尔曼参数的文件路径
server 172.16.100.0 255.255.255.0   #指定虚拟局域网占用的IP地址段和子网掩码，此处配置的服务器自身占用10.0.0.1。
ifconfig-pool-persist ipp.txt   #服务器自动给客户端分配IP后，客户端下次连接时，仍然采用上次的IP地址(第一次分配的IP保存在ipp.txt中，下一次分配其中保存的IP)。
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 202.96.209.5"
push "dhcp-option DNS 8.8.8.8"
tls-auth /usr/local/open***/config/ta.key 0    #开启TLS-auth，使用ta.key防御攻击。服务器端的第二个参数值为0，客户端的为1。
keepalive 10 120      #每10秒ping一次，连接超时时间设为120秒。
comp-lzo              #开启***连接压缩，如果服务器端开启，客户端也必须开启
client-to-client      #允许客户端与客户端相连接，默认情况下客户端只能与服务器相连接
persist-key
persist-tun           #持久化选项可以尽量避免访问在重启时由于用户权限降低而无法访问的某些资源。
status /var/log/open***/open***-status.log
log /var/log/open***/open***.log
log-append /var/log/open***/open***.log           #日志保存路径
verb 4                #指定日志文件的记录详细级别，可选0-9，等级越高日志内容越详细
explicit-exit-notify 2        #服务端重启，客户端自动重连
auth-user-pass-verify /usr/local/open***/config/checkpsw.sh via-env  #用户密码认证脚本
client-cert-not-required  #关闭证书认证方式
username-as-common-name    #用户登陆
script-security 3    #安全脚本方式认证
```
## 二、client参数详解
```
client #指定当前***是客户端
dev tun #必须与服务器端的保持一致
;proto udp #必须与服务器端的保持一致
proto tcp
remote 192.168.1.123 1194 #指定连接的远程服务器的实际IP地址和端口号
resolv-retry infinite #断线自动重新连接，在网络不稳定的情况下(例如：笔记本电>脑无线网络)非常有用。
nobind #不绑定特定的本地端口号
persist-key
persist-tun
ca ca.crt #指定CA证书的文件路径
#cert client2.crt #指定当前客户端的证书文件路径
#key client2.key #指定当前客户端的私钥文件路径
ns-cert-type server #指定采用服务器校验方式
tls-auth ta.key 1 #如果服务器设置了防御DoS等攻击的ta.key，则必须每个客户端开启；如果未设置，则注释掉这一行；
comp-lzo #与服务器保持一致
log-append open***.log
verb 4 #指定日志文件的记录详细级别，可选0-9，等级越高日志内容越详细
auth-user-pass #用户密码认证
```

参考文档:

http://blog.51cto.com/ljohn/1961351
