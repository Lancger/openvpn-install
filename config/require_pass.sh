## 服务器配置文件
#server.conf

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
auth-user-pass-verify /etc/openvpn/checkpsw.sh via-env
client-cert-not-required
username-as-common-name
script-security 3
status openvpn-status.log
log openvpn.log
verb 3

## 客户端配置文件
#client.ovpn

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
comp-lzo               #传输内容压缩,这个参数必须要，不然网络不通
verb 3                 #日志级别
auth-user-pass
