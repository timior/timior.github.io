---
title: centos7 离线rpm包安装mysql数据库
date: 2017-07-22 02:50:38
tags: Centos7,Mysql
category: logs
---
centos7 离线rpm包安装mysql数据库
<!--more-->


## 系统环境
系统：Centos7  64位
Mysql版本：[mysql-5.7.19-1.el7.x86_64.rpm-bundle.tar](https://dev.mysql.com/downloads/mysql/) 由于Centos7使用的是Redhat的内核版本，因此操作系统选择Red Hat Enterprise Linux/Oracle Linux  
注：所有的安装命令均在root用户下执行
---
##安装包上传
使用WinSCP等工具将下载好的mysql-5.7.19-1.el7.x86_64.rpm-bundle.tar上传到Centos7的任意目录，如  
mkdir -p /opt/mysql 将文件上传到/opt/mysql目录 tar xvf mysql-5.7.19-1.el7.x86_64.rpm-bundle.tar解压
解压后结果如下：
```
[hadoop@bdas1 mysql]$ ls -lrt
total 1157956
-rw-r--r--. 1 7155 31415  25085192 Jun 24 20:08 mysql-community-client-5.7.19-1.el7.x86_64.rpm
-rw-r--r--. 1 7155 31415   3778852 Jun 24 20:08 mysql-community-devel-5.7.19-1.el7.x86_64.rpm
-rw-r--r--. 1 7155 31415    278292 Jun 24 20:08 mysql-community-common-5.7.19-1.el7.x86_64.rpm
-rw-r--r--. 1 7155 31415  46236988 Jun 24 20:08 mysql-community-embedded-5.7.19-1.el7.x86_64.rpm
-rw-r--r--. 1 7155 31415  24077820 Jun 24 20:08 mysql-community-embedded-compat-5.7.19-1.el7.x86_64.rpm
-rw-r--r--. 1 7155 31415 128296360 Jun 24 20:09 mysql-community-embedded-devel-5.7.19-1.el7.x86_64.rpm
-rw-r--r--. 1 7155 31415   2238032 Jun 24 20:09 mysql-community-libs-5.7.19-1.el7.x86_64.rpm
-rw-r--r--. 1 7155 31415   2115696 Jun 24 20:09 mysql-community-libs-compat-5.7.19-1.el7.x86_64.rpm
-rw-r--r--. 1 7155 31415  55456196 Jun 24 20:09 mysql-community-minimal-debuginfo-5.7.19-1.el7.x86_64.rpm
-rw-r--r--. 1 7155 31415 171537176 Jun 24 20:09 mysql-community-server-5.7.19-1.el7.x86_64.rpm
-rw-r--r--. 1 7155 31415  15258732 Jun 24 20:09 mysql-community-server-minimal-5.7.19-1.el7.x86_64.rpm
-rw-r--r--. 1 7155 31415 118490200 Jun 24 20:10 mysql-community-test-5.7.19-1.el7.x86_64.rpm
-rw-r--r--. 1 root root  592865280 Jul 22 16:08 mysql-5.7.19-1.el7.x86_64.rpm-bundle.tar
```

##安装Mysql
使用rpm安装包安装Mysql无需事先创建mysql用户和mysql用户组，安装的初始化过程程序会自动创建mysql的用户和用户组，这个自动创建的用户不允许使用shell等方式登录，其内部的创建命令如下
```
#无需创建用户和组
shell> groupadd mysql
shell> useradd -r -g mysql -s /bin/false mysql
```
安装前需要先检测系统里是否存在系统里是否已存在mysql,如果有需要先卸载
```
rpm -qa |grep mysql
yum remove mysql-community-libs-5.7.19-1.el7.x86_64
```
此外还需使用删除机器上所有有关mysql的库文件（通常是mariadb的依赖库）使用find / -name mysql查找是否存在依赖库，使用yum remove mysql-libs删除依赖库
```
[root@bdas1 mysql]# find / -name mysql
/usr/lib64/mysql
/usr/share/mysql
/opt/mysql
[root@bdas1 ~]# yum remove mysql-libs
[root@bdas1 ~]# find / -name mysql
```
通常来说只需安装四个rpm包即可，四个rpm是存在依赖的，因此需要按顺序安装
```
rpm -ivh mysql-community-common-5.7.19-1.el7.x86_64.rpm
rpm -ivh mysql-community-libs-5.7.19-1.el7.x86_64.rpm
rpm -ivh mysql-community-client-5.7.19-1.el7.x86_64.rpm
rpm -ivh mysql-community-server-5.7.19-1.el7.x86_64.rpm
```
##初始化

##mysql环境

1、使用 --initialize参数 初始化时生成随机root密码,密码在/var/log/mysqld.log 日志文件中  

```
mysqld --initialize --user=mysql
systemctl start mysqld
mysql -u root -p (输入/var/log/mysqld.log文件中的密码)
mysql> alter user 'root'@'localhost'  identified  by  '新密码';
```

2、使用--initialize-insecure参数，初始化时不产生随机密码，之后再创建密码

```
mysqld --initialize-insecure --user=mysql
systemctl start mysqld
mysql -u root --skip-password
mysql> alter user 'root'@'localhost'  identified  by  '新密码';
```

启动mysql数据库：Centos7启动系统服务的密令格式，相对Centos6有些不同，  
```
#Centos 7
systemctl start mysqld
systemctl stop mysqld
systemctl status mysqld

#Centos 6
service mysqld start
service mysqld stop
service mysqld status
```
***
检测是否启动
```
[root@bdas1 mysql]# netstat -ntlp  | grep 3306
tcp6       0      0 :::3306                 :::*                    LISTEN      4692/mysqld 
[root@bdas1 sbin]# ps -ef|grep mysql
mysql     1593     1  0 21:25 ?        00:00:01 /usr/sbin/mysqld --daemonize --pid-file=/var/run/mysqld/mysqld.pid
root      2775  2686  0 22:18 pts/0    00:00:00 grep --color=auto mysql
```


---
## 修改Mysql数控datedir目录

1、修改/etc/sysconfig/selinux将SELINUX的值修改为disabled （需要重启）

```
# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
#     enforcing - SELinux security policy is enforced.
#     permissive - SELinux prints warnings instead of enforcing.
#     disabled - No SELinux policy is loaded.
SELINUX=disabled
```
2、vi /etc/my.cnf修改datedir和socket
```
#datadir=/var/lib/mysql
#socket=/var/lib/mysql/mysql.sock

datadir=/appdata/mysql
socket=/appdata/mysql/mysql.sock

#此外还需修改[client]的socket配置路径
[client]
socket=/appdata/mysql/mysql.sock
```
3、将源datadir的目录拷贝到修改后的目的目录，并修改目录权限，最后建链接
```
cp -rf /var/lib/mysql /appdata/mysql
cd /appdata
chown -R mysql mysql
chgrp -R mysql mysql

```
4、测试是否修改成功

```
systemctl start mysqld
mysql -u root -p
```

错误1：第一步中修改/etc/sysconfig/selinux文件中的SELINUX，没有重启，重启即可，日志信息如下

```
[root@bdas1 appdata]# systemctl start mysqld
Job for mysqld.service failed because the control process exited with error code. See "systemctl status mysqld.service" and "journalctl -xe" for details.

[root@bdas1 appdata]# systemctl status mysqld.service
● mysqld.service - MySQL Server
   Loaded: loaded (/usr/lib/systemd/system/mysqld.service; enabled; vendor preset: disabled)
   Active: failed (Result: start-limit) since Sat 2017-07-22 23:22:56 CST; 5s ago
     Docs: man:mysqld(8)
     ....

而且/var/log/mysqld.log文件错误如下
2017-07-22T13:06:03.966795Z 0 [Note] InnoDB: If the mysqld execution user is authorized, page cleaner thread priority can be changed. See the man page of setpriority().
2017-07-22T13:06:03.977001Z 0 [ERROR] InnoDB: Operating system error number 13 in a file operation.
2017-07-22T13:06:03.977025Z 0 [ERROR] InnoDB: The error means mysqld does not have the access rights to the directory.
2017-07-22T13:06:03.977028Z 0 [ERROR] InnoDB: os_file_get_status() failed on './ibdata1'. Can't determine file permissions
2017-07-22T13:06:03.977032Z 0 [ERROR] InnoDB: Plugin initialization aborted with error Generic error
2017-07-22T13:06:04.585249Z 0 [ERROR] Plugin 'InnoDB' init function returned error.
2017-07-22T13:06:04.585284Z 0 [ERROR] Plugin 'InnoDB' registration as a STORAGE ENGINE failed.
2017-07-22T13:06:04.585290Z 0 [ERROR] Failed to initialize plugins.
```
错误2：systemctl start mysqld命令正确执行，但是mysql登录报错，且日志如下

```
[root@bdas1 sbin]# mysql
ERROR 2002 (HY000): Can't connect to local MySQL server through socket '/var/lib/mysql/mysql.sock' (2)

解决方式有两种，推荐使用方式一
1、增加clinet的socket目录设置，vi /etc/my.cnf，在文件末尾增加如下内容即可,须重启
[client]
socket=/appdata/mysql/mysql.sock

2、建立链接ln -s /appdata/mysql/mysql.sock /var/lib/mysql/即可
对于为什么需要建立链接不太清楚
```



