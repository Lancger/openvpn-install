## 一、Openvpn 本地密码验证

```bash
# 安装
wget https://git.io/vpn -O openvpn-install.sh && bash openvpn-install.sh

https://github.com/Nyr/openvpn-install

# 基于用户名密码验证
1.修改配置文件。（添加下列配置）

auth-user-pass-verify /etc/openvpn/checkpsw.sh via-env　　　　#开启用户密码脚本

client-cert-not-required　　　　　　　　　　　　　　　　　　　　　  #取消客户端的证书认证　　如果双重验证注释掉此行，客户端配置文件证书路径保留。

username-as-common-name　　　　　　　　　　　　　　　　

script-security 3　　　　　　　　　　　　　　　　　　　　　　　　     #加入script-security消除以下警告  不是很了解，不加拨号失败（允许OPenvpn使用用户自动以脚本）

2.添加验证脚本，密码文件。

[root@openvpn openvpn]# vim checkpsw.sh　　#验证脚本  设定好权限　chmod 400 checkpsw.sh 　chmod +x checkpsw.sh   不要弄反了

 
checkpsw.sh权限设置为：-rwxr--r-- (744)

 
所有者：nobody

 
chown nobody:nobody checkpsw.sh     #需要先cd到该目录

 
脚本如下，自行copy并命名为checkpsw.sh

 

checkpsw.sh脚本可以通过网络获取

wget http://openvpn.se/files/other/checkpsw.sh

checkpsw.sh默认从文件/etc/openvpn/psw-file中读取用户名密码。
```

参考文档：

https://www.cnblogs.com/sunpear/p/5722482.html
