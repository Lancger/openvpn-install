## 一、一键安装vpn

```bash
 
[root@localhost mnt]# wget https://git.io/vpn -O openvpn-install.sh;bash openvpn-install.sh 
Welcome to this OpenVPN "road warrior" installer!
 
I need to ask you a few questions before starting the setup.
You can leave the default options and just press enter if you are ok with them.
 
First, provide the IPv4 address of the network interface you want OpenVPN
listening to.
IP address: 10.50.215.95                      ----直接回车
 
This server is behind NAT. What is the public IPv4 address or hostname?
Public IP address / hostname: 10.50.215.95    ---填写本机外网ip
 
Which protocol do you want for OpenVPN connections?  --默认1可以直接回车，自行选择
   1) UDP (recommended)
   2) TCP
Protocol [1-2]: 2
 
What port do you want OpenVPN listening to?         --默认1可以直接回车，自行选择
Port: 1194
 
Which DNS do you want to use with the VPN?          --默认1可以直接回车，自行选择
   1) Current system resolvers
   2) 1.1.1.1
   3) Google
   4) OpenDNS
   5) Verisign
DNS [1-5]: 3
 
Finally, tell me your name for the client certificate.
Please, use one word only, no special characters.
Client name: client                     --创建vpn用户，默认client，可以直接回车，自行选择
………………………………………………………………………………………………………………………………
………………………………………………………………………………………………………………………………
Your client configuration is available at: /root/client.ovpn
If you want to add more clients, you simply need to run this script again!
```

## 二、使用vpn创建和删除用户，以及卸载vpn

```bash
 
[root@localhost mnt]# bash openvpn-install.sh 
Looks like OpenVPN is already installed.
 
What do you want to do?
   1) Add a new user
   2) Revoke an existing user
   3) Remove OpenVPN
   4) Exit
Select an option [1-4]: 1    ~~~~~~~~--创建vpn用户
 
Tell me a name for the client certificate.
Please, use one word only, no special characters.
Client name: zzh            ~~~~~~~~~--需要创建vpn用户的名称
 
Using SSL: openssl OpenSSL 1.0.2k-fips  26 Jan 2017
Generating a 2048 bit RSA private key
........+++
......................................................................+++
writing new private key to '/etc/openvpn/easy-rsa/pki/private/zzh.key.qnPYHHswQl'
-----
Using configuration from ./safessl-easyrsa.cnf
Check that the request matches the signature
Signature ok
The Subject's Distinguished Name is as follows
commonName            :ASN.1 12:'zzh'
Certificate is to be certified until Jan  1 01:30:50 2029 GMT (3650 days)
 
Write out database with 1 new entries
Data Base Updated
 
Client zzh added, configuration is available at: /root/zzh.ovpn   ~~~~~~~---登录vpn的秘钥，下载到widows系统的桌面上
```
