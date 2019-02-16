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

## 二、服务器证书
```
[root@openvpn ~]# ls /usr/share/easy-rsa/3.0.3/     #easy-rsa3的版本只有如下几个文件、目录，比2版本少了很多
easyrsa  openssl-1.0.cnf  x509-types    
[root@openvpn ~]# mkdir /etc/openvpn/easy-rsa
[root@openvpn ~]# cp -r /usr/share/easy-rsa/3.0.3/* /etc/openvpn/easy-rsa/
```
参考资料：

http://www.89cool.com/807.html
