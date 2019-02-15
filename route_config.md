```
打印路由
route print   打印所有路由

增加路由
route add 目标网络 mask 子网掩码 网关 [接口]（可省略） 
route add 160.12.0.0 mask 255.255.0.0 160.12.0.3
route add 160.12.0.0 mask 255.255.0.0 160.12.0.2


删除路由
删除一段所有160.12.0.0的路由：
route delete 160.12.0.0

删除一条路由
route delete +网络目标+网关 
route delete 160.12.0.0 160.12.0.1

修改路由
route change 网段 mask 子网掩码 [网关]（可省略） 
route change 160.12.0.2 mask 255.255.0.0 160.12.0.10
```

https://blog.csdn.net/qq_36743482/article/details/73610171  windows删除路由

参考文档：


https://www.52os.net/articles/openvpn-add-local-routing-table.html

https://hbaaron.github.io/blog_2017/openvpn%E8%B7%AF%E7%94%B1%E9%85%8D%E7%BD%AE/
