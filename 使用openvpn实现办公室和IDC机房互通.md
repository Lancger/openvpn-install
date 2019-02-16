 使用openvpn实现办公室和IDC机房互通

最近上线了一个项目，服务器放在郑州的IDC机房，运维需要在广州办公室远程管理服务器，因此采用OPENVPN架设vpn服务器，打通办公室和IDC机房之间的网络。

服务器和网络规划如下：

我们的目的是让广州办公室内网 172.16.0.0/24、172.16.2.0/24 网段可以和郑州IDC机房内网172.16.101.0/24、10.140.3.100/24网段互通

环境说明：

    在郑州IDC机房选一台主机 172.25.101.105 作为openvpn服务器，监听在10000端口，映射为外网的 222.143.53.139 的10000端口
    在广州办公室选一台主机 172.16.0.55 作为 openvpn客户端，连接openvpn服务器端
    客户端连接成功后可以把广州（vpnclient）和 （vpnserver）看成两个路由
    广州办公室的内网主机如果想访问郑州IDC机房的内网主机，需要添加静态路由，把去往郑州IDC机房的目标网段下一跳指到 （vpnclient）172.16.0.55
    郑州IDC机房的内网主机如果想访问广州办公室内网主机，需要添加静态路由，把去往广州办公室的目标网段下一跳指到 （vpnserver）172.25.101.105

 
一、郑州opevpn服务配置 （172.25.101.105）

端口映射

将openvpn服务器172.25.101.105的10000端口映射为外网222.143.53.199的10000端口（因为没有公网地址，在实际的生产环境有公网地址、双网卡是最好的）

开启路由转发

编辑 /etc/sysctl.conf 文件将 net.ipv4.ip_forward = 0 改为  net.ipv4.ip_forward = 1，然后执行

sysctl -p

配置openvpn服务端

编辑服务端配置文件/etc/openvpn/server.conf
复制代码

local 172.25.101.105
port 10000
proto tcp
dev tun
ca /etc/openvpn/easy-rsa/keys/ca.crt
cert /etc/openvpn/easy-rsa/keys/vpnserver.crt
key /etc/openvpn/easy-rsa/keys/vpnserver.key 
dh /etc/openvpn/easy-rsa/keys/dh2048.pem
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push "route 172.25.101.0 255.255.255.0" # 推送路由给客户端，通知客户端添加静态路由，让客户端去这两个网段走vpn接口(tun0)
push "route 10.140.3.0 255.255.255.0"
route 172.16.0.0 255.255.255.0          # 给openvpn服务器添加静态路由，目的是让openvpn服务器知道怎么去客户端网段，走vpn接口(tun0)
client-config-dir /etc/openvpn/ccd
keepalive 10 120
comp-lzo
max-clients 120
user nobody
group nobody
client-to-client
duplicate-cn                         # 多个用户用同一个证书，根据生产环境需求配置
persist-key
persist-tun
status /var/log/openvpn/openvpn-status.log
log /var/log/openvpn/openvpn.log
writepid /var/run/openvpn/server.pid 
verb 3 mute 20

复制代码

为广州客户端生成证书

# cd /etc/openvpn/easy-rsa
# ./build-key gz

指定gz客户端配置

/etc/openvpn/ccd/gz

iroute 172.16.0.0 255.255.255.0     # 客户端声明自己的网段是172.16.0.0
ifconfig-push 10.8.0.5 10.8.0.6     # 配置客户端IP

启动openvpn服务端

# service openvpn start
# chkconfig --add openvpn
# chkconfig --level 35 openvpn on

查看tun0接口和路由表
复制代码

# ifconfig tun0
tun0      Link encap:UNSPEC  HWaddr 00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00  
          inet addr:10.8.0.1  P-t-P:10.8.0.2  Mask:255.255.255.255
          UP POINTOPOINT RUNNING NOARP MULTICAST  MTU:1500  Metric:1
          RX packets:9909 errors:0 dropped:0 overruns:0 frame:0
          TX packets:561 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:100 
          RX bytes:784296 (765.9 KiB)  TX bytes:130132 (127.0 KiB)

# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
10.8.0.2        0.0.0.0         255.255.255.255 UH    0      0        0 tun0 # 主机路由
10.8.0.0        10.8.0.2        255.255.255.0   UG    0      0        0 tun0 # 静态路由，去目标网段10.8.0.0下一跳是10.8.0.2 走vpn接口(tun0)
172.16.0.0      10.8.0.2        255.255.255.0   UG    0      0        0 tun0 # 静态路由，去目标网段172.16.0.0下一跳是10.8.0.2 走vpn接口(tun0)
172.25.101.0    0.0.0.0         255.255.255.0   U     0      0        0 eth0 # 直连路由
169.254.0.0     0.0.0.0         255.255.0.0     U     1002   0        0 eth0 # 直连路由
0.0.0.0         172.25.101.254  0.0.0.0         UG    0      0        0 eth0 # 直连路由

复制代码
二、广州openvpn客户端配置（172.16.0.55）

开启路由转发，编辑 /etc/sysctl.conf 文件将 net.ipv4.ip_forward = 0 改为  net.ipv4.ip_forward = 1，然后执行

sysctl -p

编辑客户端配置文件/etc/openvpn/client.conf
复制代码

client
dev tun
proto tcp
remote 222.143.53.139 10000
resolv-retry infinite
nobind
persist-key
persist-tun
ca   keys/ca.crt
cert keys/gz.crt
key  keys/gz.key
remote-cert-tls server
auth-nocache
user nobody
group nobody
comp-lzo
status   /var/log/openvpn/openvpn-status.log
log      /var/log/openvpn/openvpn.log
writepid /var/run/openvpn/client.pid
verb 3
mute 20

复制代码

启动openvpn客户端

service openvpn start
chkconfig --add openvpn
chkconfig --level 35 openvpn on

查看tun0接口和路由表
复制代码

# ifconfig tun0
tun0      Link encap:UNSPEC  HWaddr 00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00  
          inet addr:10.8.0.5  P-t-P:10.8.0.6  Mask:255.255.255.255
          UP POINTOPOINT RUNNING NOARP MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:100 
          RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)

# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
10.8.0.6        0.0.0.0         255.255.255.255 UH    0      0        0 tun0
10.140.3.0      10.8.0.6        255.255.255.0   UG    0      0        0 tun0
10.8.0.0        10.8.0.6        255.255.255.0   UG    0      0        0 tun0
172.16.0.0      0.0.0.0         255.255.255.0   U     0      0        0 eth0
172.25.101.0    10.8.0.6        255.255.255.0   UG    0      0        0 tun0
169.254.0.0     0.0.0.0         255.255.0.0     U     1002   0        0 eth0
0.0.0.0         172.16.0.1      0.0.0.0         UG    0      0        0 eth0

复制代码

测试到openvpn服务端是不是通的，如果能通说明OK
复制代码

# ping 172.25.101.105
PING 172.25.101.105 (172.25.101.105) 56(84) bytes of data.
64 bytes from 172.25.101.105: icmp_seq=1 ttl=64 time=27.5 ms
64 bytes from 172.25.101.105: icmp_seq=2 ttl=64 time=28.0 ms
64 bytes from 172.25.101.105: icmp_seq=3 ttl=64 time=26.3 ms
64 bytes from 172.25.101.105: icmp_seq=4 ttl=64 time=26.8 ms

--- 172.25.101.105 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3076ms
rtt min/avg/max/mdev = 26.365/27.202/28.081/0.690 ms

复制代码

此时广州的vpn客户端和郑州的vpn服务端可以看成两个路由
三、功能验证

1、广州的172.16.0.0段和郑州的172.25.101.0段互通

方法一： 广州172.16.0.0段主机与郑州172.25.101.0段主机分别添加路由

广州172.16.0.0段主机添加静态路由，去目标网络 172.25.101.0 段下一跳是vpn客户端 ( 172.16.0.55 )

ip route add  172.25.101.0/24 via 172.16.0.55                 //linux
route add 172.25.101.0/24 mask 255.255.255.0 172.16.0.55      //windows

郑州 172.25.101.0 段主机添加静态路由，去目标网络 172.25.101.0 段下一跳是vpn服务端 ( 172.25.101.105 )

ip route add 172.16.0.0/24 via 172.25.101.105                //linux
route add 172.16.0.0/24 mask 172.25.101.105                  //windows

但是这种方法有个问题，如果主机数量很多，每台主机就需要添加路由，比较麻烦，所以推荐方法二

方法二、 在内网路由设备添加静态路由

在广州172.16.0.0段的网关设备（内网路由器）上添加静态路由，让目标网络 172.25.101.0 的下一跳是 172.16.0.55

在郑州州172.25.101.0段的网关设备（内网路由器）上添加静态路由，让目标网络 172.16.0.0 的下一跳是 172.25.101.105

这种方式好处就是在路由器上配置，不用在主机上添加路由，比较省事。（注：内网路由器通常是网关设备，比如路由器、三层交换机等，可以让负责这块的人配置）

最后测试广州和郑州两个网段能不能互通，如果可以说明ok了

在广州172.16.0.0段的主机ping郑州172.25.101.10这台主机
复制代码

# ping 172.25.101.10  # ok
PING 172.25.101.10 (172.25.101.10) 56(84) bytes of data.
64 bytes from 172.25.101.10: icmp_seq=1 ttl=62 time=28.3 ms
64 bytes from 172.25.101.10: icmp_seq=2 ttl=62 time=27.0 ms
64 bytes from 172.25.101.10: icmp_seq=3 ttl=62 time=26.9 ms
--- 172.25.101.10 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2472ms
rtt min/avg/max/mdev = 26.916/27.440/28.319/0.653 ms

复制代码

跟踪下路由表，看包的走向
复制代码

# traceroute 172.25.101.10
traceroute to 172.25.101.10 (172.25.101.10), 30 hops max, 60 byte packets
 1  172.16.0.1 (172.16.0.1)  8.032 ms  8.959 ms  10.025 ms         # 先到内网路由器（网关），我这里是(172.16.0.1)
 2  172.16.0.55 (172.16.0.55)  0.468 ms  0.482 ms  0.478 ms        # 数据转发到广州vpn客户端  (172.16.0.55)      
 3  10.8.0.1 (10.8.0.1)  27.439 ms  54.006 ms  80.127 ms           # vpn客户端转发给vpn服务端（这步已经到了服务端）
 4  172.25.101.10 (172.25.101.10)  80.131 ms  80.130 ms  80.119 ms # 最后包到了目标主机

复制代码

在郑州的 172.25.101.0段的主机ping广州172.16.0.31这台主机
复制代码

# ping 172.16.0.31  # ok
PING 172.16.0.31 (172.16.0.31) 56(84) bytes of data.
64 bytes from 172.16.0.31: icmp_seq=1 ttl=125 time=27.1 ms
64 bytes from 172.16.0.31: icmp_seq=2 ttl=125 time=26.5 ms
64 bytes from 172.16.0.31: icmp_seq=3 ttl=125 time=27.0 ms
64 bytes from 172.16.0.31: icmp_seq=4 ttl=125 time=26.9 ms
^C
--- 172.16.0.31 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3147ms
rtt min/avg/max/mdev = 26.524/26.917/27.159/0.242 ms

复制代码

跟踪下路由表，看包的走向
复制代码

# traceroute 172.16.0.31
traceroute to 172.16.0.31 (172.16.0.31), 30 hops max, 60 byte packets
 1  172.25.101.254 (172.25.101.254)  0.230 ms  0.210 ms  0.125 ms # 先到内网路由器（网关），我这里是（172.25.101.254）
 2  172.25.101.105 (172.25.101.105)  0.170 ms  0.140 ms  0.125 ms # 然后到vpn服务端（172.25.101.105）
 3  10.8.0.5 (10.8.0.5)  72.398 ms  138.712 ms  138.710 ms        # 数据转发给广州vpn客户端
 4  bogon (172.16.0.31)  138.697 ms * *                           # 最后到目标主机

复制代码

2、广州的172.16.2.0段能通郑州的172.25.101.0段

如果想让广州内网172.16.2.0通郑州的172.25.101.0端，可以在广州的vpn客户端(172.16.0.55) 上添加SNAT规则

让源地址是172.16.2.0段的伪装成vpn客户端172.16.0.55

# iptables -t nat -A POSTROUTING -s 172.16.2.0/24 -j SNAT --to-source 172.16.0.55
# service iptables save



参考文档:

https://www.cnblogs.com/huangweimin/articles/7712771.html#4171910
