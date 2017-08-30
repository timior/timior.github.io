---
title: Centos7 安装Ansible 
date: 2017-08-03 23:00:00
tags: Centos7, Ansible
category: logs
---
Centos7 64位 在线、离线安装Ansible

<!--more-->


## 系统环境
系统：Centos7  64位


## rpm在线安装Ansible
```
# 安装EPEL源  
yum install wget
wget http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -ivh epel-release-latest-7.noarch.rpm

# 安装ansible
yum install ansible
```

## rpm离线安装Ansible
由于没有直观的网址下载rpm包，因此最简单的方法是新建一台最小化安装的CentOs7虚拟机，  
之后修改/etc/yum.conf，将keepcache=0修改为keepcache=1，之后使用在线安装的方式安装ansible，
在cash目录：cachedir=/var/cache/yum/下寻找所有的依赖包。
根据在线安装的屏显顺序手工安装rpm包

### 在线安装的屏显信息
```
Running transaction
警告：RPM 数据库已被非 yum 程序修改。
  正在安装    : python-six-1.9.0-2.el7.noarch                                                                                                       1/19 
  正在安装    : python2-ecdsa-0.13-4.el7.noarch                                                                                                     2/19 
  正在安装    : sshpass-1.06-1.el7.x86_64                                                                                                           3/19 
  正在安装    : python-babel-0.9.6-8.el7.noarch                                                                                                     4/19 
  正在安装    : libtommath-0.42.0-5.el7.x86_64                                                                                                      5/19 
  正在安装    : libtomcrypt-1.17-25.el7.x86_64                                                                                                      6/19 
  正在安装    : python2-crypto-2.6.1-13.el7.x86_64                                                                                                  7/19 
  正在安装    : python2-paramiko-1.16.1-2.el7.noarch                                                                                                8/19 
  正在安装    : python-backports-1.0-8.el7.x86_64                                                                                                   9/19 
  正在安装    : python-backports-ssl_match_hostname-3.4.0.2-4.el7.noarch                                                                           10/19 
  正在安装    : python-setuptools-0.9.8-4.el7.noarch                                                                                               11/19 
  正在安装    : python2-pyasn1-0.1.9-7.el7.noarch                                                                                                  12/19 
  正在安装    : python-keyczar-0.71c-2.el7.noarch                                                                                                  13/19 
  正在安装    : python-httplib2-0.7.7-3.el7.noarch                                                                                                 14/19 
  正在安装    : python-markupsafe-0.11-10.el7.x86_64                                                                                               15/19 
  正在安装    : python-jinja2-2.7.2-2.el7.noarch                                                                                                   16/19 
  正在安装    : libyaml-0.1.4-11.el7_0.x86_64                                                                                                      17/19 
  正在安装    : PyYAML-3.10-11.el7.x86_64                                                                                                          18/19 
  正在安装    : ansible-2.3.1.0-1.el7.noarch                                                                                                       19/19 
```
### 离线安装脚本如下：
```
# 安装包名称即在上一步安装名称后加.rpm后缀（建议使用列编辑器编写安装脚本）  
rpm -ivh python-six-1.9.0-2.el7.noarch.rpm
rpm -ivh python2-ecdsa-0.13-4.el7.noarch.rpm
rpm -ivh sshpass-1.06-1.el7.x86_64.rpm
rpm -ivh python-babel-0.9.6-8.el7.noarch.rpm
rpm -ivh libtommath-0.42.0-5.el7.x86_64.rpm
rpm -ivh libtomcrypt-1.17-25.el7.x86_64.rpm
rpm -ivh python2-crypto-2.6.1-13.el7.x86_64.rpm
rpm -ivh python2-paramiko-1.16.1-2.el7.noarch.rpm
rpm -ivh python-backports-1.0-8.el7.x86_64.rpm
rpm -ivh python-backports-ssl_match_hostname-3.4.0.2-4.el7.noarch.rpm
rpm -ivh python-setuptools-0.9.8-4.el7.noarch.rpm
rpm -ivh python2-pyasn1-0.1.9-7.el7.noarch.rpm
rpm -ivh python-keyczar-0.71c-2.el7.noarch.rpm
rpm -ivh python-httplib2-0.7.7-3.el7.noarch.rpm
rpm -ivh python-markupsafe-0.11-10.el7.x86_64.rpm
rpm -ivh python-jinja2-2.7.2-2.el7.noarch.rpm
rpm -ivh libyaml-0.1.4-11.el7_0.x86_64.rpm
rpm -ivh PyYAML-3.10-11.el7.x86_64.rpm
rpm -ivh ansible-2.3.1.0-1.el7.noarch.rpm
```







