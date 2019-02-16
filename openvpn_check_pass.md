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
script-security 3　　　　　　　　　　　　　　　　　　　　　　　　    #加入script-security消除以下警告  不是很了解，不加拨号失败（允许OPenvpn使用用户自动以脚本）

2.添加验证脚本，密码文件。
[root@openvpn openvpn]# vim /etc/openvpn/checkpsw.sh　　#验证脚本  

#设定好权限
cd /etc/openvpn/
chown nobody:nobody checkpsw.sh     
chmod 744 checkpsw.sh 　
chmod +x checkpsw.sh   

checkpsw.sh  脚本可以通过网络获取
wget -O /etc/openvpn/checkpsw.sh http://openvpn.se/files/other/checkpsw.sh

3.脚本详细内容
#!/bin/sh
###########################################################
# checkpsw.sh (C) 2004 Mathias Sundman <mathias@openvpn.se>
#
# This script will authenticate OpenVPN users against
# a plain text file. The passfile should simply contain
# one row per user with the username first followed by
# one or more space(s) or tab(s) and then the password.
 
PASSFILE="/etc/openvpn/psw-file"
LOG_FILE="/etc/openvpn/openvpn-password.log"
TIME_STAMP=`date "+%Y-%m-%d %T"`
 
###########################################################
 
if [ ! -r "${PASSFILE}" ]; then
  echo "${TIME_STAMP}: Could not open password file \"${PASSFILE}\" for reading." >> ${LOG_FILE}
  exit 1
fi
 
CORRECT_PASSWORD=`awk '!/^;/&&!/^#/&&$1=="'${username}'"{print $2;exit}' ${PASSFILE}`
 
if [ "${CORRECT_PASSWORD}" = "" ]; then
  echo "${TIME_STAMP}: User does not exist: username=\"${username}\", password=\"${password}\"." >> ${LOG_FILE}
  exit 1
fi
 
if [ "${password}" = "${CORRECT_PASSWORD}" ]; then
  echo "${TIME_STAMP}: Successful authentication: username=\"${username}\"." >> ${LOG_FILE}
  exit 0
fi
 
echo "${TIME_STAMP}: Incorrect password: username=\"${username}\", password=\"${password}\"." >> ${LOG_FILE}
exit 1


checkpsw.sh 默认从文件/etc/openvpn/psw-file 中读取用户名密码。

4.密码验证文件　　
chmod 400 psw-file　
chown nobody.nobody psw-file


psw-file 中一行是一个账号，用户名和密码之间用空格隔开
username   password

5.修改客户端配置
vim client.ovpn

注销掉这两行 
#cert peara.crt
#key peara.key

再添加这一行，添加这行，就会提示输入用户名和密码
auth-user-pass

6.最后重启服务

systemctl start openvpn@server
```

参考文档：

https://www.cnblogs.com/sunpear/p/5722482.html
