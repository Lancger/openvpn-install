## 一、安装openvpn
```bash
yum install -y epel-release
yum install -y openvpn easy-rsa openssl openssl-devel lzo lzo-devel pam pam-devel automake pkgconfig

上述命令执行完成后，会有一个/etc/openvpn的目录，通常我们把配置文件都放在这个目录下。
```

1.查看openvpn版本：
```
openvpn --version |head -n1

```
2.复制服务端配置文件到配置文件目录
```
[root@openvpn ~]# cp /usr/share/doc/openvpn-2.4.6/sample/sample-config-files/server.conf /etc/openvpn/
```

参考资料：

http://www.89cool.com/807.html
