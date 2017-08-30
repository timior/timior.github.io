centos7 在线安装 ambari

# 系统环境，6台虚拟机，2台作为master节点，4台作为slave节点 


## 关防火墙，关SELINUX(注：关SELINUX需要重启才会有效)
```
systemctl stop firewalld
systemctl disable firewalld
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
```

## 网络配置
```
cat > /etc/hosts << EOF
192.168.56.10 master1.bigdata.com master1
192.168.56.11 master2.bigdata.com master2
192.168.56.12 slave1.bigdata.com slave1
192.168.56.13 slave2.bigdata.com slave2
192.168.56.14 slave3.bigdata.com slave3
192.168.56.15 slave4.bigdata.com slave4
EOF
```
## java环境 :
安装目录: /usr/java/jdk   版本：jdk1.8.0_111   
```
cat >> /etc/profile << EOF
# BEGIN ANSIBLE JAVA ENVVAR
export JAVA_HOME=/usr/java/jdk
export CLASSPATH=.:$JAVA_HOME/jre/lib/rt.jar:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
export PATH=$PATH:$JAVA_HOME/bin
# END ANSIBLE JAVA ENVVAR 
EOF
```

## mysql 环境 mysql 5.7
先创建repo文件，然后yum install 安装
```
cat >> /etc/yum.repos.d/mysql-community.repo << EOF
[mysql57-community]
name=MySQL 5.7 Community Server
baseurl=http://repo.mysql.com/yum/mysql-5.7-community/el/7/$basearch/
enabled=1
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql
EOF

yum repolist all | grep mysql
yum install mysql-community-server
```

## 在mysql数据库中创建ambari数据库
为 


















# mysql repo
cat >> /etc/yum.repos.d/mysql-community.repo << EOF
[mysql57-community]
name=MySQL 5.7 Community Server
baseurl=http://repo.mysql.com/yum/mysql-5.7-community/el/7/$basearch/
enabled=1
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql
EOF
yum repolist all | grep mysql
yum install mysql-community-server











：








# Prerequisites install
# Prerequisites install
yum install rpm
yum install curl
yum install wget
wget -p ~/ http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -ivh ~/epel-release-latest-7.noarch.rpm
rm -f ~/epel-release-latest-7.noarch.rpm
yum install pdsh

# install mysql192.168.56.10 master1.bigdata.com master1
192.168.56.11 master2.bigdata.com master2
192.168.56.12 slave1.bigdata.com slave1
192.168.56.13 slave2.bigdata.com slave2
192.168.56.14 slave3.bigdata.com slave3
192.168.56.15 slave4.bigdata.com slave4
# mysql repo
cat >> /etc/yum.repos.d/mysql-community.repo << EOF
[mysql57-community]
name=MySQL 5.7 Community Server
baseurl=http://repo.mysql.com/yum/mysql-5.7-community/el/7/$basearch/
enabled=1
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql
EOF
yum repolist all | grep mysql
yum install mysql-community-server



mysql_repo="/etc/yum.repos.d/mysql-community.repo"
echo '[mysql57-community]' > "$mysql_repo"
echo 'name=MySQL 5.7 Community Server' >> "$mysql_repo"
echo 'baseurl=http://repo.mysql.com/yum/mysql-5.7-community/el/7/$basearch/' >> "$mysql_repo"
echo 'enabled=1' >> "$mysql_repo"
echo 'gpgcheck=0' >> "$mysql_repo"
echo 'gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql' >> "$mysql_repo"
yum repolist all | grep mysql
yum install mysql-community-server 

# ambari
wget -O /etc/yum.repos.d/ambari.repo http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.5.1.0/ambari.repo
yum install ambari-server -y

#创建用户:ambari,修改用户密码为ambari
useradd ambari
echo "ambari:ambari" | chpasswd

# stop firewalld
systemctl stop firewalld

# disable SELINUX
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

# enable cash
sed -i 's/keepcache=0/keepcache=1/g' /etc/yum.conf

# JAVA_HOME
echo '#LANG' >> /etc/profile
echo 'export LC_ALL="zh_CN.GBK"' >> /etc/profile
echo 'export LANG="zh_CN.GBK"' >> /etc/profile
echo '' >> /etc/profile
echo '# BEGIN ANSIBLE JAVA ENVVAR ' >> /etc/profile
echo 'export JAVA_HOME=/usr/java/jdk' >> /etc/profile
echo 'export CLASSPATH=.:$JAVA_HOME/jre/lib/rt.jar:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar' >> /etc/profile
echo 'export PATH=$PATH:$JAVA_HOME/bin' >> /etc/profile
echo '# END ANSIBLE JAVA ENVVAR ' >> /etc/profile

# mysql jdbc driver
wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.43.tar.gz
tar zxvf mysql-connector-java-5.1.43.tar.gz
mkdir -p /usr/share/java
cp ./mysql-connector-java-5.1.43/mysql-connector-java-5.1.43-bin.jar /usr/share/java/
rm -rf mysql-connector-java-5.1.43.tar.gz mysql-connector-java-5.1.43
amb_profile="/etc/ambari-server/conf/ambari.properties"
echo "server.jdbc.driver.path=/usr/share/java/mysql-connector-java-5.1.43-bin.jar" >> "${amb_profile}"

#create the schema
echo "create database ambari;"
echo "mysql> use ambari;"
echo 'mysql> CREATE USER 'ambari'@'%' IDENTIFIED BY 'ambari';'
echo 'mysql> GRANT ALL PRIVILEGES ON *.* TO 'ambari'@'%';'
echo 'mysql> CREATE USER 'ambari'@'master.bigdata.com' IDENTIFIED BY 'ambari';'
echo 'mysql> GRANT ALL PRIVILEGES ON *.* TO 'ambari'@'master.bigdata.com';'
echo 'mysql> CREATE USER 'ambari'@'ambari' IDENTIFIED BY 'ambari';'
echo 'mysql> GRANT ALL PRIVILEGES ON *.* TO 'ambari'@'ambari';'
echo 'mysql> FLUSH PRIVILEGES;'
echo "mysql> source /var/lib/ambari-server/resources/Ambari-DDL-MySQL-CREATE.sql"
mysql -uroot -p

echo "create database hive;"
echo "mysql> use hive"
echo 'mysql> CREATE USER 'hive'@'%' IDENTIFIED BY 'hive';'
echo 'mysql> GRANT ALL PRIVILEGES ON *.* TO 'hive'@'%';'
echo 'mysql> CREATE USER 'hive'@'master.bigdata.com' IDENTIFIED BY 'hive';'
echo 'mysql> GRANT ALL PRIVILEGES ON *.* TO 'hive'@'master.bigdata.com';'
echo 'mysql> CREATE USER 'hive'@'hive' IDENTIFIED BY 'hive';'
echo 'mysql> GRANT ALL PRIVILEGES ON *.* TO 'hive'@'hive';'
echo 'mysql> FLUSH PRIVILEGES;'
echo "mysql> source /var/lib/ambari-server/resources/Ambari-DDL-MySQL-CREATE.sql"
mysql -uroot -p


systemctl restart mysqld
# setup ambari
ambari-server setup

# start ambari
su - ambari
ambari-server start
ambari-server stop

#HDP SITE  https://docs.hortonworks.com/HDPDocuments/Ambari-2.5.1.0/bk_ambari-installation/content/hdp_26_repositories.html
yum install httpd
wget http://public-repo-1.hortonworks.com/HDP/centos7/2.x/updates/2.6.1.0/HDP-2.6.1.0-centos7-rpm.tar.gz
wget http://public-repo-1.hortonworks.com/HDP-UTILS-1.1.0.21/repos/centos7/HDP-UTILS-1.1.0.21-centos7.tar.gz





# stop firewalld
systemctl stop firewalld
systemctl disable firewalld

# disable SELINUX
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

# -----------------rpm--------------------
rpm -ivh rpm-libs-4.11.3-21.el7.x86_64.rpm
rpm -ivh rpm-4.11.3-21.el7.x86_64.rpm
rpm -ivh rpm-build-libs-4.11.3-21.el7.x86_64.rpm
rpm -ivh rpm-python-4.11.3-21.el7.x86_64.rpm
# -----------------curl--------------------
rpm -ivh libcurl-7.29.0-35.el7.centos.x86_64.rpm
rpm -ivh curl-7.29.0-35.el7.centos.x86_64.rpm
# -----------------wget--------------------
rpm -ivh wget-1.14-13.el7.x86_64.rpm
# -----------------pdsh--------------------
rpm -ivh perl-parent-0.225-244.el7.noarch.rpm
rpm -ivh perl-HTTP-Tiny-0.033-3.el7.noarch.rpm
rpm -ivh perl-podlators-2.5.1-3.el7.noarch.rpm
rpm -ivh perl-Pod-Perldoc-3.20-4.el7.noarch.rpm
rpm -ivh perl-Pod-Escapes-1.04-291.el7.noarch.rpm

rpm -ivh perl-Encode-2.51-7.el7.x86_64.rpm
rpm -ivh perl-Text-ParseWords-3.29-4.el7.noarch.rpm
rpm -ivh perl-Pod-Usage-1.63-3.el7.noarch.rpm
rpm -ivh perl-Storable-2.45-3.el7.x86_64.rpm
rpm -ivh perl-Exporter-5.68-3.el7.noarch.rpm

rpm -ivh perl-constant-1.27-2.el7.noarch.rpm
rpm -ivh perl-Time-Local-1.2300-2.el7.noarch.rpm
rpm -ivh perl-Socket-2.010-4.el7.x86_64.rpm
rpm -ivh perl-Carp-1.26-244.el7.noarch.rpm
rpm -ivh perl-Time-HiRes-1.9725-3.el7.x86_64.rpm

rpm -ivh perl-Pod-Simple-3.28-4.el7.noarch.rpm
rpm -ivh perl-PathTools-3.40-5.el7.x86_64.rpm
rpm -ivh perl-Scalar-List-Utils-1.27-248.el7.x86_64.rpm
rpm -ivh perl-libs-5.16.3-291.el7.x86_64.rpm
rpm -ivh perl-macros-5.16.3-291.el7.x86_64.rpm

rpm -ivh perl-File-Temp-0.23.01-3.el7.noarch.rpm
rpm -ivh perl-File-Path-2.09-2.el7.noarch.rpm
rpm -ivh perl-threads-shared-1.43-6.el7.x86_64.rpm
rpm -ivh perl-threads-1.87-4.el7.x86_64.rpm
rpm -ivh perl-Filter-1.49-3.el7.x86_64.rpm

rpm -ivh perl-Getopt-Long-2.40-2.el7.noarch.rpm
rpm -ivh perl-5.16.3-291.el7.x86_64.rpm
rpm -ivh pdsh-rcmd-ssh-2.31-1.el7.x86_64.rpm
rpm -ivh pdsh-2.31-1.el7.x86_64.rpm

# -----------------mysql--------------------
# 清除mariadb版本的mysql-libs
yum remove mysql-libs
rpm -ivh net-tools-2.0-0.17.20131004git.el7.x86_64.rpm
rpm -ivh mysql-community-common-5.7.19-1.el7.x86_64.rpm
rpm -ivh mysql-community-libs-5.7.19-1.el7.x86_64.rpm
rpm -ivh mysql-community-libs-compat-5.7.19-1.el7.x86_64.rpm
rpm -ivh mysql-community-client-5.7.19-1.el7.x86_64.rpm
rpm -ivh mysql-community-server-5.7.19-1.el7.x86_64.rpm
# 初始化mysql
mysqld --initialize-insecure --user=mysql
systemctl start mysqld
#设置mysql的root密码
mysql -u root --skip-password

# -----------------ambari--------------------
# install ambari
rpm -ivh postgresql-libs-9.2.18-1.el7.x86_64.rpm
rpm -ivh postgresql-9.2.18-1.el7.x86_64.rpm
rpm -ivh postgresql-server-9.2.18-1.el7.x86_64.rpm
rpm -ivh ambari-server-2.5.1.0-159.x86_64.rpm

# stop firewalld
systemctl stop firewalld
systemctl disable firewalld

# disable SELINUX
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config


# JAVA_HOME
cat >> /etc/profile << EOF
# BEGIN ANSIBLE JAVA ENVVAR
export JAVA_HOME=/usr/java/jdk
export CLASSPATH=.:$JAVA_HOME/jre/lib/rt.jar:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
export PATH=$PATH:$JAVA_HOME/bin
END ANSIBLE JAVA ENVVAR 
EOF


echo '#LANG' >> /etc/profile
echo 'export LC_ALL="zh_CN.GBK"' >> /etc/profile
echo 'export LANG="zh_CN.GBK"' >> /etc/profile
echo '' >> /etc/profile
echo '# BEGIN ANSIBLE JAVA ENVVAR ' >> /etc/profile
echo 'export JAVA_HOME=/usr/java/jdk' >> /etc/profile
echo 'export CLASSPATH=.:$JAVA_HOME/jre/lib/rt.jar:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar' >> /etc/profile
echo 'export PATH=$PATH:$JAVA_HOME/bin' >> /etc/profile
echo '# END ANSIBLE JAVA ENVVAR ' >> /etc/profile
source /etc/profile

# hosts
echo '192.168.56.100 master.bigdata.com master' > /etc/hosts
echo '192.168.56.101 slave1.bigdata.com slave1' >> /etc/hosts
echo '192.168.56.102 slave2.bigdata.com slave2' >> /etc/hosts
echo '192.168.56.103 slave3.bigdata.com slave3' >> /etc/hosts


http://192.168.56.100:8080/api/v1/clusters/c1

master.bigdata.com
slave1.bigdata.com
slave2.bigdata.com
slave3.bigdata.com

# mysql jdbc driver
wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.43.tar.gz

mkdir -p /usr/share/java
cp ./mysql-connector-java-5.1.43-bin.jar /usr/share/java/

tar zxvf jdk-8u111-linux-x64.tar.gz
ln -s jdk1.8.0_111 jdk

# setup ambari
ambari-server setup

# start ambari
ambari-server start
ambari-server stop

# HDP
http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.5.1.0/ambari-2.5.1.0-centos7.tar.gz
http://public-repo-1.hortonworks.com/HDF/centos7/2.x/updates/2.6.1.0/HDP-2.6.1.0-centos7-rpm.tar.gz

http://public-repo-1.hortonworks.com/HDP/centos7/2.x/updates/2.6.1.0/HDP-2.6.1.0-centos7-rpm.tar.gz
http://public-repo-1.hortonworks.com/HDP-UTILS-1.1.0.21/repos/centos7/HDP-UTILS-1.1.0.21-centos7.tar.gz

  yum-plugin-priorities.noarch 0:1.1.31-40.el7                                                                                                                               


rpm -ivh apr-1.4.8-3.el7.x86_64.rpm
rpm -ivh apr-util-1.5.2-6.el7.x86_64.rpm
rpm -ivh httpd-tools-2.4.6-45.el7.centos.4.x86_64.rpm
rpm -ivh mailcap-2.1.41-2.el7.noarch.rpm
rpm -ivh httpd-2.4.6-45.el7.centos.4.x86_64.rpm
systemctl start httpd.service
systemctl status httpd.service
systemctl restart httpd.service
echo '/usr/sbin/apachectl start' >> /etc/rc.d/rc.local
chmod +x /etc/rc.d/rc.local




http://192.168.56.90/HDP/centos7/


http://public-repo-1.hortonworks.com/HDP/centos7/2.x/updates/2.6.0.3
http://public-repo-1.hortonworks.com/HDP-UTILS-1.1.0.21/repos/centos7




vi /etc/yum.repos.d/ambari.repo

#VERSION_NUMBER=2.5.1.0-159
[ambari-2.5.1.0]
name=ambari Version - ambari-2.5.1.0
#http://<web.server>/Ambari-2.5.1.0/<OS>
baseurl=http://master.bigdata.com/Ambari-2.5.1.0/centos7
gpgcheck=0
#gpgkey=http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.5.1.0/RPM-GPG-KEY/RPM-GPG-KEY-Jenkins
enabled=1
priority=1


#VERSION_NUMBER=2.6.1.0-129
[hdp-2.6.1.0]
name=hdp Version - hdp-2.6.1.0
baseurl=http://master.bigdata.com/hdp/HDP/centos7/
gpgcheck=1
gpgkey=http://master.bigdata.com/hdp/HDP/centos7/RPM-GPG-KEY/RPM-GPG-KEY-Jenkins
enabled=1
priority=1


[HDP-UTILS-1.1.0.21]
name=HDP-UTILS Version - HDP-UTILS-1.1.0.21
baseurl=http://master.bigdata.com/hdp/HDP-UTILS-1.1.0.21/
gpgcheck=1
gpgkey=http://master.bigdata.com/hdp/HDP-UTILS-1.1.0.21/RPM-GPG-KEY/RPM-GPG-KEY-Jenkins
enabled=1
priority=1



ssh-copy-id -i ~/.ssh/id_rsa.pub root@master.bigdata.com


ERR:Ambari Bootstrap process timed out. It was destroyed.
root 


yum install ntp

  正在安装    : autogen-libopts-5.18-5.el7.x86_64                                                                                 1/3 
  正在安装    : ntpdate-4.2.6p5-25.el7.centos.2.x86_64                                                                            2/3 
  正在安装    : ntp-4.2.6p5-25.el7.centos.2.x86_64   
yum install chrony
  正在安装    : chrony-2.1.1-4.el7.centos.x86_64                                                                                  1/1 


切回ntpd：
systemctl disable chronyd.service -l
systemctl stop chronyd.service -l
systemctl status chronyd.service -l
systemctl restart ntpd.service
systemctl status ntpd.service
systemctl enable ntpd.service
ntpq -p
ntpstat


切回chronyd：
systemctl stop ntpd.service
systemctl disable ntpd.service
systemctl enable chronyd.service -l
systemctl restart chronyd.service -l
systemctl status chronyd.service -l
chronyc sourcestats
chronyc sources -v









[ambari@pcliu java]$ ambari-server setup
Using python  /usr/bin/python
Setup ambari-server
Ambari-server setup is run with root-level privileges, passwordless sudo access for some commands commands may be required
Checking SELinux...
SELinux status is 'enabled'
SELinux mode is 'permissive'
WARNING: SELinux is set to 'permissive' mode and temporarily disabled.
OK to continue [y/n] (y)? y
Customize user account for ambari-server daemon [y/n] (n)? y
Enter user account for ambari-server daemon (ambari):ambari
ERROR: Failed: [Errno 13] Permission denied
ERROR: Exiting with exit code 4. 
REASON: Failed to create user. Exiting.
[ambari@pcliu java]$ su root
密码：
[root@pcliu java]# ambari^C
[root@pcliu java]# ^C
[root@pcliu java]# ambari-server setup
Using python  /usr/bin/python
Setup ambari-server
Checking SELinux...
SELinux status is 'enabled'
SELinux mode is 'permissive'
WARNING: SELinux is set to 'permissive' mode and temporarily disabled.
OK to continue [y/n] (y)? y
Customize user account for ambari-server daemon [y/n] (n)? y
Enter user account for ambari-server daemon (ambari):ambari
Adjusting ambari-server permissions and ownership...
Checking firewall status...
Checking JDK...
Do you want to change Oracle JDK [y/n] (n)? y
[1] Oracle JDK 1.8 + Java Cryptography Extension (JCE) Policy Files 8
[2] Oracle JDK 1.7 + Java Cryptography Extension (JCE) Policy Files 7
[3] Custom JDK
==============================================================================
Enter choice (1): 3
WARNING: JDK must be installed on all hosts and JAVA_HOME must be valid on all hosts.
WARNING: JCE Policy files are required for configuring Kerberos security. If you plan to use Kerberos,please make sure JCE Unlimited Strength Jurisdiction Policy Files are valid on all hosts.
Path to JAVA_HOME: /^H
ERROR: Exiting with exit code 1. 
REASON: Downloading or installing JDK failed: 'Fatal exception: Java home path or java binary file is unavailable. Please put correct path to java home., exit code 1'. Exiting.
[root@pcliu java]# ambari-server setup
Using python  /usr/bin/python
Setup ambari-server
Checking SELinux...
SELinux status is 'enabled'
SELinux mode is 'permissive'
WARNING: SELinux is set to 'permissive' mode and temporarily disabled.
OK to continue [y/n] (y)? 
Customize user account for ambari-server daemon [y/n] (n)? ^C
Aborting ... Keyboard Interrupt.
[root@pcliu java]# ambari-server setup
Using python  /usr/bin/python
Setup ambari-server
Checking SELinux...
SELinux status is 'enabled'
SELinux mode is 'permissive'
WARNING: SELinux is set to 'permissive' mode and temporarily disabled.
OK to continue [y/n] (y)? y
Customize user account for ambari-server daemon [y/n] (n)? y
Enter user account for ambari-server daemon (ambari):ambari
Adjusting ambari-server permissions and ownership...
Checking firewall status...
Checking JDK...
Do you want to change Oracle JDK [y/n] (n)? y
[1] Oracle JDK 1.8 + Java Cryptography Extension (JCE) Policy Files 8
[2] Oracle JDK 1.7 + Java Cryptography Extension (JCE) Policy Files 7
[3] Custom JDK
==============================================================================
Enter choice (1): 3
WARNING: JDK must be installed on all hosts and JAVA_HOME must be valid on all hosts.
WARNING: JCE Policy files are required for configuring Kerberos security. If you plan to use Kerberos,please make sure JCE Unlimited Strength Jurisdiction Policy Files are valid on all hosts.
Path to JAVA_HOME: /usr/java/jdk
Validating JDK on Ambari Server...done.
Completing setup...
Configuring database...
Enter advanced database configuration [y/n] (n)? y
Configuring database...
==============================================================================
Choose one of the following options:
[1] - PostgreSQL (Embedded)
[2] - Oracle
[3] - MySQL / MariaDB
[4] - PostgreSQL
[5] - Microsoft SQL Server (Tech Preview)
[6] - SQL Anywhere
[7] - BDB
==============================================================================
Enter choice (3): 3
Hostname (pcliu): pcliu
Port (3306): 
Database name (ambari): ambari
Username (ambari): ambari
Enter Database Password (ambari): 
Configuring ambari database...
Configuring remote database connection properties...
WARNING: Before starting Ambari Server, you must run the following DDL against the database to create the schema: /var/lib/ambari-server/resources/Ambari-DDL-MySQL-CREATE.sql
Proceed with configuring remote database connection properties [y/n] (y)y
Extracting system views...
............
Adjusting ambari-server permissions and ownership...
Ambari Server 'setup' completed successfully.





dfs.client.read.shortcircuit



dfs.client.read.shortcircuit


hbase.rootdir =  file:///var/var/lib/ambari-metrics-collector/hbase
hbase.tmp.dir=/var/lib/ambari-metrics-collector/hbase-tmp
mkdir -p /apdata/ambari/hbase/
mkdir -p /apdata/ambari/hbase/tmp

ZooKeeper directory = /appdata/ambari/zookeeper/data
ZooKeeper Log Dir= /appdata/ambari/zookeeper/log
ZooKeeper PID Dir= /appdata/ambari/zookeeper/pid

Metrics Collector log dir = /appdata/ambari/metrics/collector/log
Metrics Collector pid dir = /appdata/ambari/metrics/collector/pid
Metrics Monitor log dir =   /appdata/ambari/metrics/monitor/log
Metrics Collector pid dir = /appdata/ambari/metrics/monitor/pid

Aggregator checkpoint directory =/appdata/ambari/metrics/collector/checkpoint
Metrics Grafana data dir = /appdata/ambari/metrics/grafana/data
Metrics Grafana log dir = /appdata/ambari/metrics/grafana/log
Metrics Grafana pid dir = /appdata/ambari/metrics/grafana/pid

 hdfs://master.bigdata.com:8020/amshbase
hbase_log_dir = /appdata/ambari/metrics/collector/log
hbase_pid_dir = /appdata/ambari/metrics/collector/hbase_pid

hbase.rootdir = /appdata/ambari/metrics/collector/hbase/data
hbase.tmp.dir = /appdata/ambari/metrics/collector/hbase/data/tmp



/var/log/ambari-metrics-collector

/appdata/ambari/metrics/collector/log


##HDFS 
NameNode = /appdata/ambari/hadoop/hdfs/namenode,/opt/ambari/hadoop/hdfs/namenode

DataNode = /appdata/ambari/hadoop/hdfs/data,/opt/ambari/hadoop/hdfs/data
dfs.journalnode.edits.dir= /appdata/ambari/hadoop/hdfs/journalnode


fs.defaultFS=hdfs://master.bigdata.com:8020


a















