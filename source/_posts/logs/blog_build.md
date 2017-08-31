---
title: 个人博客搭建过程随手笔记
date: 2017-05-20 02:50:38
tags: Hexo,github
category: logs
---
个人博客的搭建日志，记录博客搭建过程的中的一些心得，由衷感谢Grok的博客对我的指导。

<!--more-->

## 系统环境

开发平台：Windows
开发工具：[Hexo](https://hexo.io/)
博客主题：[Next](http://theme-next.iissnan.com/)

## Hexo 环境搭建
搭建过程主要参考 [Grok](http://lowrank.science/)的博客
[知行合一 | 用 Hexo 搭建博客](http://lowrank.science/Hexo-Github/)
[Hexo 搭建博客教程补遗](http://lowrank.science/Hexo-Addendum/)

主要步骤如下：
1、[git](https://git-scm.com/downloads)工具安装
2、[wget](https://jaist.dl.sourceforge.net/project/gnuwin32/wget/1.11.4-1/wget-1.11.4-1-setup.exe)工具安装
   将下载的wget.exe文件放入 C:\Windows\System32 目录即可使用wget密令
3、[node.js](https://nodejs.org)工具安装
4、[Hexo](https://hexo.io/)工具安装

实用工具 npm install -g cnpm --registry=https://registry.npm.taobao.org
安装模块时只要用 cnpm 替换 npm 即可，会直接从淘宝 NPM 安装，安装命令形如：cnpm install [name]

## Hexo 博客压缩优化

Hexo主程序并不对生成的页面进行优化，致使页面内容稀疏，由于网面大小的会直接影响网页打开的速度，因此对页面进行压缩是有必要的。简单来说有两种可选方式进行生成网页的压缩优化。
方式一：使用gulp插件，自行编写优化脚本，如[hexo博客－性能优化](http://www.cnblogs.com/jarson-7426/p/5660424.html)
方式二：使用Hexo软件的配套插件，如：[hexo-neat](https://github.com/rozbo/hexo-neat) 、[hexo-all-minifier](https://github.com/chenzhutian/hexo-all-minifier)、[hexo-filter-cleanup](https://github.com/mamboer/hexo-filter-cleanup)

本博客采用的是[hexo-all-minifier](https://github.com/chenzhutian/hexo-all-minifier)插件
```
 npm install hexo-all-minifier --save
# hexo 的根目录下修改配置文件
 all_minifier: true
```


## git管理博客
使用Hexo搭建的博客，其源文件(.md文件)并不会上传到git上去，当更换电脑或者重装系统，博客的管理将会是个问题，个人尝试使用分支的方式来管理个人博客
1. 在博客搭建好后，在博客的根目录下创建git分支,如：我的博客根目录为/d/WorkSpace/myblog/blog,首先打开git Bash(使用ssh方式,需先在github上增加本地rsa公钥) 使用`git checkout --orphan branch-sourcen` 创建无关分支（--orphan），并将其提交到远程的github上，这时在githup上将会看到两个分支
提交成功，删除从master分支继承过来的所有无用文件
2. 将博客根目录下的source文件拷贝到步骤1创建的分支目录中，之后提交到远程githup
操作命令如下
```
# 个人博客根目录为/d/WorkSpace/myblog/blog，githup博客地址为timior.github.io
cd /d/WorkSpace/myblog/blog
git clone git@github.com:timior/timior.github.io.git
git checkout --orphan branch-source
cd timior.github.io
git add .
git commit -m "create branch-source"
git push origin branch-source
git rm -rf .
cp -rf ../source .
git add .
git commit -m "blog source file"
git push origin branch-source
```
3、为了能够便捷的管理，编写辅助脚本(所谓便捷:就是能一条语句解决的问题,绝不写两条)，将脚本与hexo脚本至于同一目录(在git Bash中使用`which hexo` 可查找hexo所在目录),脚本名称取为hexoo（注:文件名不应有后缀）
其中:hexoo spush 执行hexo deploy,并从博客的source目录拷贝文件到branch-source分支(即从本地同步都远程github)
其中:hexoo spull 执行git pull origin branch-source 将远程github上branch-source分支拷贝到博客的source文件夹（即从远程github同步到本地)
其中:--config "$themeConf","$themeConf",使用hexo 3.0的新特性,以便于统一管理插件的升级(参考[next的安装说明](https://github.com/iissnan/hexo-theme-next))
```
#!/bin/sh
# blogRoot Hexo博客的根目录
blogRoot="/d/WorkSpace/myblog/blog"
repoName="timior.github.io"
rootConf=source/_data/next.yml
themeConf=source/_data/_config.yml

cd "$blogRoot"

if [[ "$1" == g* ]]
then
	hexo clean --config "$themeConf","$themeConf"
	hexo generate --config "$themeConf","$themeConf"
elif [[ "$1" == se* ]]
then
	hexo clean --config "$themeConf","$themeConf"
	hexo generate --config "$themeConf","$themeConf"
	hexo server --config "$themeConf","$themeConf"
elif [[ "$1" == d* ]]
then
 	hexo clean --config "$themeConf","$themeConf"
	hexo generate --config "$themeConf","$themeConf"
	hexo deploy --config "$themeConf","$themeConf"
elif [[ "$1" == spush* ]]
then
	hexo clean --config "$themeConf","$themeConf"
	hexo generate --config "$themeConf","$themeConf"
	hexo deploy --config "$themeConf","$themeConf"
 	cd "$repoName/"
	git pull origin branch-source
	cp -rf ../source/ .
	git add .
	git commit -m "`date`"
	git push origin branch-source
elif [[ "$1" == spull* ]]
then
 	cd "$repoName/"
	git checkout branch-source
	rm -rf source
	git pull origin branch-source
	cp -rf source/ ../
else
	echo "Usage:" 
	echo "hexoo g			# hexo clean && generate"
	echo "hexoo s			# hexo clean && generate && server"
	echo "hexoo d			# hexo clean && generate && deploy"
	echo "hexoo spush		# hexo clean && generate && deploy && deploy source file to branch-source"
	echo "hexoo spull		# git pull origin branch-source,get remote source file and merge it to local file,then copy to blogroot/source"
	echo ""
fi
```
## Markdown 编辑工具[Typora](https://www.typora.io/)

由于Hexo不能够在页面上实时显示正在编写的文档，每次查看编写效果都需要执行如下指令，繁琐而不直观。

``` codes
$ hexo clean
$ hexo generate
$ hexo server
```


## Hexo 页面底部注释
由hexo的模板自动生成的页面，在底部默认会有版权和主体的注释，如图：
![](http://oqaxv1vwu.bkt.clouddn.com//image/blog/logs/blog_build/blog_copyright_orignal.PNG)
容易暴露个人智商，作为强迫症患者，简直无法忍受。经过查找，底框代码是在：{% raw %} blog\themes\next\layout\_partials\ {% endraw %}目录下的footer.swig文件里说明的，修改文件内容如下：
``` codes
<div class="copyright" >
  {% set current = date(Date.now(), "YYYY") %}                
  &copy; {% if theme.since and theme.since != current %} <i> {{ theme.since }} - <\i> {% endif %}
  <span itemprop="copyrightYear"><i>{{ current }}</i></span>
  <span class="with-love"> <i class="fa fa-{{ theme.authoricon }}"> </i> </span>
  <span class="author" itemprop="copyrightHolder"> <i>Powered By - {{ config.author }} </i> </span>
</div>

{% if theme.copyright %}
<div class="copyright">
  <i>Contact Me&nbsp&nbsp&nbsp|&nbsp&nbsp&nbsp</i>
  <i><a target="_blank" rel="external" href="https://github.com/timior">https://github.com/timior</a></i>
</div>
{% endif %}
```
额外添加<i>标签，让其显示为斜体字，在 "|" 字符两边添加多个&nbsp，插入空格让其看上去更加简洁，最后显示效果如下:
![](http://oqaxv1vwu.bkt.clouddn.com//image/blog/logs/blog_build/blog_copyright_new.PNG)

## 评论系统插件
Hexo的Neat主体里面已经集成了几种评论工具[插件](http://theme-next.iissnan.com/third-party-services.html)，个人先尝试了网易云跟帖，整体感觉并不好，因为网易留言回复采用的是”楼上楼“方式，可经过几轮回复留言区会变得一片混乱，跟本找不到谁是谁的留言，之后尝试了[来必力](https://livere.com/)，使用感觉还不错，留言回复采用的是“楼中楼”方式，直观清晰，具体可浏览本博客的留言区域。不过有个缺点，这个插件貌似不支持留言导入导出的功能，这意味着，一旦上了船就别想再跑了，此外这个插件是韩国的，我电脑所在电信网络，注册登录总是出现出现网络故障，无赖最后使用手机网络来注册登录，感觉手机网络还是很给力的。
![](http://oqaxv1vwu.bkt.clouddn.com//image/blog/logs/blog_build/blog_qiniu_add7.PNG)

## 博客图床-七牛云
由于博客托管在github上面，加载速度本来就慢，如果还需加载大量的图片，那就更加无法忍受了，所以图床是必须要有的，见大家都推荐使用[七牛云](https://www.qiniu.com/)，尝试了下，加载速度还不错，步骤如下：
### 一：注册七牛云，新建对象存储空间
![](http://oqaxv1vwu.bkt.clouddn.com//image/blog/logs/blog_build/blog_qiniu_add6.PNG)
![](http://oqaxv1vwu.bkt.clouddn.com//image/blog/logs/blog_build/blog_qiniu_add2.PNG)

### 二：进入存储空间-内容管理-上传文件
![](http://oqaxv1vwu.bkt.clouddn.com//image/blog/logs/blog_build/blog_qiniu_add3.PNG)

在右边可以添加文件的前缀（先填写右侧的文件路径，再添加文件，就会给文件自动加上前缀）
![](http://oqaxv1vwu.bkt.clouddn.com//image/blog/logs/blog_build/blog_qiniu_add5.PNG)

### 三：图片的使用
七牛云上上传的图片，可以在页面里直接使用，无需添加任何设置，复制图片路径，哪里要引用就粘哪，在Hexo的markdown里引用方式之一：```![](粘入复制的链接)```
![](http://oqaxv1vwu.bkt.clouddn.com//image/blog/logs/blog_build/blog_qiniu_add4.PNG)


## To be Continued...
