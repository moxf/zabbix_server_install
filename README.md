### zabbix服务端一键安装脚本
#### 功能说明
通过shell脚本读取配置文件构建ansible-playbook，编译安装lnmp+zabbix_server

#### 测试环境信息
|选项|描述|
|----|----|
|操作系统|centos 7.5.1804|
|nginx安装包|nginx-1.14.1.tar.gz|
|php安装包|php-7.3.12.tar.gz|
|mysql安装包|mysql-5.7.24-linux-glibc2.12-x86_64.tar.gz|
|zabbix安装包|zabbix-4.0.15.tar.gz|
|所有组件部署在同一台机|172.17.0.129|


#### 主要安装略
- 基础部署信息
1. 软件包皆部署于/opt
2. 日志皆配置于/log
3. 数据存于/data


- nginx
1. 依赖pcre pcre-8.42.tar.gz
2. 安装后端健康检测模块nginx_upstream_check_module-master.zip
3. 编译安装

- php
1. 升级libzip libzip-1.2.0.tar.gz
2. 编译安装

- mysql 
1. 二进制方式安装

- zabbix
1. 编译安装



#### 使用说明
- 在控制机器上安装ansible并能让控制机以root用户免密登录上所有机器
```
yum -y install ansible git
```

- 下载部署脚本
```
git clone https://github.com/moxf/zabbix_server_install.git
```

- 编辑配置文件
```
cd zabbix_server_install
vim config.ini 

#修改软件包信息
nginx_package_name=xxx
nginx_upstream_check_package_name=xxx
pcre_package_name=xxx
php_package_name=xxx
libzip_package_name=xxx
mysql_package_name=xxx
zabbix_package_name=xxx

#修改hosts
nginx_host=xxx
php_host=xxx
mysql_host=xxx
zabbix_host=xxx

#修改运行用户
nginx_run_user=xxx
php_run_user=xxx
mysql_run_usr=xxx
zabbix_run_user=xxx

- 将所列出的软件包拷贝到本工程目录下的src目录


- 执行setup.sh安装
```
bash setup.sh
```

- 查看结果
1. 浏览器打开http://zabbix主机ip
