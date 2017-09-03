---
title: centos7 在线安装 Ambari （一）
date: 2017-08-03 23:00:00
category: 
	- Bigdata
	- Ambari
tags: 
	- Centos7
	- Ambari
---
Centos7 64位 在线安装 Ambari

<!--more-->

centos7 在线安装 ambari

# 系统环境，4台虚拟机，1台作为master节点，3台作为slave节点

## 关防火墙，关SELINUX(注：关SELINUX需要重启才会有效)
```
systemctl stop firewalld
systemctl disable firewalld
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
cat /etc/selinux/config
```
## 网络配置
```
#预留slave4作为集群添加删除节点测试
cat > /etc/hosts << EOF
192.168.56.10 master1.bigdata.com master1
192.168.56.11 slave1.bigdata.com slave1
192.168.56.12 slave2.bigdata.com slave2
192.168.56.13 slave3.bigdata.com slave3
192.168.56.14 slave4.bigdata.com slave4
EOF
```
## 主机名配置
```
# master1 节点
echo "master1" > /etc/hostname
# slave1 节点
echo "slave1" > /etc/hostname
# slave2 节点
echo "slave2" > /etc/hostname
# 以此类推
```
## java环境 :
安装目录: /usr/java/jdk   版本：jdk1.8.0_111   
```
cat >> /etc/profile << EOF
# BEGIN ANSIBLE JAVA ENVVAR
export JAVA_HOME=/usr/java/jdk
export CLASSPATH=.:\$JAVA_HOME/jre/lib/rt.jar:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar
export PATH=\$PATH:\$JAVA_HOME/bin
# END ANSIBLE JAVA ENVVAR 
EOF
```

## 更改yum源镜像地址  
```
# 备份
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
# 获取repo
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
```

# ambari 安装
由于ambari的源在国外，下载速度过慢，容易出现安装失败的情况，因此先建立本地源，之后从本地源进行安装，采用httpd来建立源服务器  
通常来说需要建的源有:ambari本地源、HDP本地源、HDP-UTILS本地源，此外安装hive,ambari还需要数据库，因此顺带建立本地Msql源
## httpd服务搭建  
```
# 安装httpd
yum install httpd

# 启动httpd
systemctl start httpd.service
systemctl status httpd.service

# 设置开机自启
echo '/usr/sbin/apachectl start' >> /etc/rc.d/rc.local
chmod +x /etc/rc.d/rc.local

# 设置http文件根目录
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.bak
sed -i 's/"\/var\/www\/html"/"\/appdata\/httpd\/www\/html"/g' /etc/httpd/conf/httpd.conf
diff /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.bak
systemctl restart httpd.service

```

## 搭建本地源：ambari、HDP、HDP-UTILS源、Mysql源  
源文件下载地址:
Ambari源	:http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.5.1.0/ambari-2.5.1.0-centos7.tar.gz
HDP源		:http://public-repo-1.hortonworks.com/HDP/centos7/2.x/updates/2.6.1.0/HDP-2.6.1.0-centos7-rpm.tar.gz
HDP-UTILS源	:http://public-repo-1.hortonworks.com/HDP-UTILS-1.1.0.21/repos/centos7/HDP-UTILS-1.1.0.21-centos7.tar.gz
Mysql源		:https://dev.mysql.com/downloads/mysql/
```
# 如果使用wget下载很慢，可以尝试使用迅雷等下载工具下载，之后上传
wget http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.5.1.0/ambari-2.5.1.0-centos7.tar.gz
wget http://public-repo-1.hortonworks.com/HDP/centos7/2.x/updates/2.6.1.0/HDP-2.6.1.0-centos7-rpm.tar.gz
wget http://public-repo-1.hortonworks.com/HDP-UTILS-1.1.0.21/repos/centos7/HDP-UTILS-1.1.0.21-centos7.tar.gz
```

将下载的文件拷贝到httpd服务的DocumentRoot目录
```
# DocumentRoot=/appdata/httpd/www/html
# 拷贝文件
mkdir -p /appdata/httpd/www/html/ambari/ambari-2.5.1.0/
mkdir -p /appdata/httpd/www/html/hdp/HDP-2.6.1.0/
mkdir -p /appdata/httpd/www/html/hdp/HDP-UTILS-1.1.0.21/
tar zxvf ambari-2.5.1.0-centos7.tar.gz -C /appdata/httpd/www/html/ambari/ambari-2.5.1.0/
tar zxvf HDP-2.6.1.0-centos7-rpm.tar.gz -C /appdata/httpd/www/html/hdp/HDP-2.6.1.0/
tar zxvf HDP-UTILS-1.1.0.21-centos7.tar.gz -C /appdata/httpd/www/html/hdp/HDP-UTILS-1.1.0.21/
```

创建ambari、HDP、HDP-UTILS源的repo文件
```
cat > /etc/yum.repos.d/ambari.repo << EOF
#VERSION_NUMBER=2.5.1.0-159
[ambari-2.5.1.0]
name=ambari Version - ambari-2.5.1.0
#http://<web.server>/Ambari-2.5.1.0/<OS>
baseurl=http://master1.bigdata.com/ambari/ambari-2.5.1.0/ambari/centos7
gpgcheck=1
gpgkey=http://master1.bigdata.com/ambari/ambari-2.5.1.0/ambari/centos7/RPM-GPG-KEY/RPM-GPG-KEY-Jenkins
enabled=1
priority=1

[hdp-2.6.1.0]
name=HDP Version - HDP-2.6.1.0
baseurl=http://master1.bigdata.com/hdp/HDP-2.6.1.0/HDP/centos7/
gpgcheck=1
gpgkey=http://master1.bigdata.com/hdp/HDP-2.6.1.0/HDP/centos7/RPM-GPG-KEY/RPM-GPG-KEY-Jenkins
enabled=1
priority=1

[HDP-UTILS-1.1.0.21]
name=HDP-UTILS Version - HDP-UTILS-1.1.0.21
baseurl=http://master1.bigdata.com/hdp/HDP-UTILS-1.1.0.21/
gpgcheck=1
gpgkey=http://master1.bigdata.com/hdp/HDP-UTILS-1.1.0.21/RPM-GPG-KEY/RPM-GPG-KEY-Jenkins
enabled=1
priority=1
EOF
```
## mysql 本地源环境搭建 mysql 5.7
使用 repocreate 工具配合httpd搭建本地Mysql源
```
# 安装repocreate
yum install repocreate

# 在httpd服务的文件目录(/appdata/httpd/www/html)下，创建源仓库目录
mkdir -p /appdata/httpd/www/html/mysql/mysql-community-5.7.19
# 使用sftp等工具将安装好的rpm包上传到/appdata/httpd/www/html/mysql/mysql-community-5.7.19目录

# 创建源仓库
createrepo /appdata/httpd/www/html/mysql/mysql-community-5.7.19

#建立repo文件
# baseurl=主机的FQDN(Fully Qualified Domain Name即主机的全域名，这里填主机的IP地址也是可行的)+ httpd目录下仓库地相当路径
cat >> /etc/yum.repos.d/mysql-community.repo << EOF
[mysql57-community]
name=MySQL 5.7 Community Server
baseurl=http://master1.bigdata.com/mysql/mysql-community-5.7.19
enabled=1
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql
EOF

# 安装mysql
# 清除默认安装的库文件
yum remove mysql-libs -y
# 安装
yum repolist all | grep mysql
yum install mysql-community-server

# 初始化mysql
mysqld --initialize-insecure --user=mysql
systemctl start mysqld
#设置mysql的root密码(mysql)
mysql -u root --skip-password
#mysql> alter user 'root'@'localhost' identified by 'mysql';
```

查看本地源安装结果,如果status-意为源中的rpm包的数目，如果大于0代表获取源信息成功
```
[root@master1 centos7]# yum repolist                                                   
Loaded plugins: fastestmirror, langpacks
HDP-UTILS-1.1.0.21                                                                     | 2.9 kB  00:00:00     
ambari-2.5.1.0                                                                         | 2.9 kB  00:00:00     
hdp-2.6.1.0                                                                            | 2.9 kB  00:00:00     
ambari-2.5.1.0/primary_db                                                              | 8.6 kB  00:00:00     
Loading mirror speeds from cached hostfile
 * base: mirrors.aliyun.com
 * extras: mirrors.aliyun.com
 * updates: mirrors.aliyun.com
repo id                                       repo name                                                 status
HDP-UTILS-1.1.0.21                            HDP-UTILS Version - HDP-UTILS-1.1.0.21                       64
ambari-2.5.1.0                                ambari Version - ambari-2.5.1.0                              12
base/7/x86_64                                 CentOS-7 - Base - mirrors.aliyun.com                      9,363
extras/7/x86_64                               CentOS-7 - Extras - mirrors.aliyun.com                      449
hdp-2.6.1.0                                   HDP Version - HDP-2.6.1.0                                   232
mysql57-community/x86_64                      MySQL 5.7 Community Server                                  207
updates/7/x86_64                              CentOS-7 - Updates - mirrors.aliyun.com                   2,146
repolist: 12,473
```


## mysql 主备同步，高可用配置，为防止master节点宕机，在master1、slave1上搭建mysql,主备机实时同步
1、修改配置文件/etc/my.cnf
```
# master1主机：在/etc/my.cnf的[mysqld]节点下添加如下信息
log-bin=mysql-bin 		开启二进制日志
server-id=1				服务ID,要求每台主机各不相同


# slave1备机：在/etc/my.cnf的[mysqld]节点下添加如下信息
log-bin=mysql-bin 		开启二进制日志
server-id=2				服务ID,要求每台主机各不相同
```
2、创建Replication用户
```
# master1 主机
mysql -u root -p
create user 'repl'@'%' identified by 'repl';
grant replication slave on *.* to 'repl'@'%';
grant replication client,replication slave on *.* to 'repl'@'192.168.72.11' identified by 'repl';

# slave1 备机
mysql -u root -p
create user 'repl'@'%' identified by 'repl';
grant replication slave on *.* to 'repl'@'%';
grant replication client,replication slave on *.* to 'repl'@'192.168.72.10' identified by 'repl';
```
3、查看两台主机的mysql bin log位置
首先将两台主机mysql中的表锁定，代表锁定表，禁止所有操作。防止bin log位置发生变化。
```
FLUSH TABLES WITH READ LOCK;
#如果两个mysql数据库里的数据不一致，需要先使用mysqldump工具导出数据同步，这里由于是新装的mysql，因此数据内容都是一致的
#mysqldump -uroot -pxxx database_name >database_name.sql
```
查看master1，slave1主机bin log位置，记录Position列的值
```
SHOW MASTER STATUS;
```
然后再解除两台主机mysql table的锁定
```
Unlock Tables;
```
4、开始设置 Slave Replication
master1 主机
```
STOP SLAVE;
CHANGE MASTER TO MASTER_HOST = '192.168.72.11', MASTER_USER = 'repl', MASTER_PASSWORD = 'repl', MASTER_LOG_FILE = 'mysql-bin.000001', MASTER_LOG_POS = 910;
START SLAVE;
```
slave1 备机
```
STOP SLAVE;
CHANGE MASTER TO MASTER_HOST = '192.168.72.10', MASTER_USER = 'repl', MASTER_PASSWORD = 'repl', MASTER_LOG_FILE = 'mysql-bin.000001', MASTER_LOG_POS = 1225;
START SLAVE;
```
5、查看两台主机是否设置成功
```
Show Slave Status;
#如果两台主机Slave_IO_Running 和Slave_SQL_Running都为YES代表设置成功。可以进行数据库操作了
#grant all privileges on *.* to root@'%' identified by 'mysql';
#flush privileges;
```


## 安装Ambari  
yum repolist all | grep ambari
yum install ambari-server


## 在mysql数据库中创建ambari数据库

为ambari-server setup做准备，在mysql数据库中创建ambari数据库
创建ambari数据脚本
```
# vi create_ambari.sql  编辑建用户脚本
create database ambari;
use ambari;
CREATE USER 'ambari'@'%' IDENTIFIED BY 'ambari';
GRANT ALL PRIVILEGES ON *.* TO 'ambari'@'%';
CREATE USER 'ambari'@'master1.bigdata.com' IDENTIFIED BY 'ambari';
GRANT ALL PRIVILEGES ON *.* TO 'ambari'@'master1.bigdata.com';
CREATE USER 'ambari'@'ambari' IDENTIFIED BY 'ambari';
GRANT ALL PRIVILEGES ON *.* TO 'ambari'@'ambari';
FLUSH PRIVILEGES;

```
# 执行脚本创建ambari数据库
```
# source /var/lib/ambari-server/resources/Ambari-DDL-MySQL-CREATE.sql; 安装Ambari时已经创建好文件
mysql -u root -p
mysql> source create_ambari.sql;
mysql> use ambari;
mysql> source /var/lib/ambari-server/resources/Ambari-DDL-MySQL-CREATE.sql;
mysql> exit;
```

# JDBC驱动
将mysql-jcdb驱动拷贝到/usr/share/java目录,配置/etc/ambari-server/conf/ambari.properties文件
```
echo "" >> /etc/ambari-server/conf/ambari.properties
echo "server.jdbc.driver.path=/usr/share/java/mysql-connector-java-5.1.43-bin.jar" >> /etc/ambari-server/conf/ambari.properties
```

# setup ambari
ambari-server setup
```
Customize user account for ambari-server daemon [y/n] (n)? n :选择否，如果选择非root用户安装，需要额外配置权限，否则会报错详情参考[Configuring Ambari for non-root access](https://www.ibm.com/support/knowledgecenter/en/SSPT3X_4.2.0/com.ibm.swg.im.infosphere.biginsights.install.doc/doc/inst_non_root.html)
Do you want to change Oracle JDK [y/n] (n)? y :选择自定义JDK,Path to JAVA_HOME: /usr/java/jdk
Enter advanced database configuration [y/n] (n)? y :选择高级选项,选择[3] - MySQL / MariaDB
Enter choice (1): 3
Hostname (localhost): master1.bigdata.com
Port (3306): 3306
Database name (ambari): ambari
Username (ambari): ambari
```
# start ambari
ambari-server start
浏览器打开http://192.168.56.10:8080/，是否能正常访问，用户名/密码:admin/admin
ambari-server stop

# 建立ssh免密登录
在master1上执行
```
ssh-keygen -t rsa  (-t:type密钥类型)
ssh-copy-id -i ~/.ssh/id_rsa.pub root@master1.bigdata.com
ssh-copy-id -i ~/.ssh/id_rsa.pub root@slave1.bigdata.com
ssh-copy-id -i ~/.ssh/id_rsa.pub root@slave2.bigdata.com
ssh-copy-id -i ~/.ssh/id_rsa.pub root@slave3.bigdata.com
ssh-copy-id -i ~/.ssh/id_rsa.pub root@slave4.bigdata.com
```

## 选择Use Local Repository
值与/etc/yum.repos.d/ambari.repo文件里配的一致

## 选择Target Hosts

## 传入rsa私钥: ~/.ssh/id_rsa(注意是id_rsa里面的值，而不是公钥)

## 启用chronyd
```
# 所有机器均需执行，用于调整内核中运行的系统时钟和时钟服务器同步
systemctl enable chronyd.service -l
systemctl restart chronyd.service -l
systemctl status chronyd.service -l
# 查看结果
chronyc sourcestats
chronyc sources -v
```
# 创建Hive数据库用户

```
vi create_hive.sql
create database hive;
use hive;
CREATE USER 'hive'@'%' IDENTIFIED BY 'hive';
GRANT ALL PRIVILEGES ON *.* TO 'hive'@'%';
CREATE USER 'hive'@'master1.bigdata.com' IDENTIFIED BY 'hive';
GRANT ALL PRIVILEGES ON *.* TO 'hive'@'master1.bigdata.com';
CREATE USER 'hive'@'hive' IDENTIFIED BY 'hive';
GRANT ALL PRIVILEGES ON *.* TO 'hive'@'hive';
FLUSH PRIVILEGES;
mysql> source create_hive.sql

```

