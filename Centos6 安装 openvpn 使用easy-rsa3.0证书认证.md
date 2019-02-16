## 一、安装openvpn
```bash
yum install -y epel-release
yum install -y openvpn easy-rsa openssl openssl-devel lzo lzo-devel pam pam-devel automake pkgconfig

上述命令执行完成后，会有一个/etc/openvpn的目录，通常我们把配置文件都放在这个目录下。
```

1.查看openvpn版本：
```
[root@openvpn ~]# openvpn --version |head -n1

OpenVPN 2.4.6 x86_64-redhat-linux-gnu [Fedora EPEL patched] [SSL (OpenSSL)] [LZO] [LZ4] [EPOLL] [PKCS11] [MH/PKTINFO] [AEAD] built on Apr 26 2018

```
2.复制服务端配置文件到配置文件目录
```
[root@openvpn ~]# cp /usr/share/doc/openvpn-2.4.6/sample/sample-config-files/server.conf /etc/openvpn/
```

## 二、服务器证书ca.crt
```
[root@openvpn ~]# ls /usr/share/easy-rsa/3.0.3/     #easy-rsa3的版本只有如下几个文件、目录，比2版本少了很多
easyrsa  openssl-1.0.cnf  x509-types

[root@openvpn ~]# mkdir /etc/openvpn/easy-rsa
[root@openvpn ~]# cp -r /usr/share/easy-rsa/3.0.3/* /etc/openvpn/easy-rsa/
```

1.ca证书制作
```
[root@openvpn ~]# cd /etc/openvpn/easy-rsa
[root@openvpn easy-rsa]# cp /usr/share/doc/easy-rsa-3.0.3/vars.example ./vars

[root@openvpn easy-rsa]# vim vars    #修改证书的相关配置，根据需要自定义，也可以忽略不设置

set_var EASYRSA_REQ_COUNTRY     "CH"          #国家
set_var EASYRSA_REQ_PROVINCE    "GuangDong"    #省
set_var EASYRSA_REQ_CITY        "ShenZhen"       #城市
set_var EASYRSA_REQ_ORG "Copyleft Certificate Co"    #组织
set_var EASYRSA_REQ_EMAIL       "test@example.net"     #邮箱
set_var EASYRSA_REQ_OU          "My Organizational Unit"    #公司、组织


[root@openvpn easy-rsa]# ./easyrsa init-pki          #初始化pki，生成目录文件结构

[root@openvpn easy-rsa]# ./easyrsa build-ca            #创建ca证书

Note: using Easy-RSA configuration from: ./vars            #使用vars文件里面配置的信息
Generating a 2048 bit RSA private key
.................+++
........................................................................................+++
writing new private key to '/etc/openvpn/easy-rsa/pki/private/ca.key.Lg8IKADc4Q'
Enter PEM pass phrase:  123456                #设置ca密码(我此处是写的123456)
Verifying - Enter PEM pass phrase: 123456     #再输一遍上面的密码
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Common Name (eg: your user, host, or server name) [Easy-RSA CA]:          #直接回车，就是默认的CA作为名字

CA creation complete and you may now import and sign cert requests.
Your new CA certificate file for publishing is at:
/etc/openvpn/easy-rsa/pki/ca.crt        #ca证书存放路径
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
```

```
参考资料：

http://www.89cool.com/807.html
