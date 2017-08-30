---
title: Spark-Job初步 
date: 2017-08-29
category: 
	- Bigdata
	- Spark
tags: 
	- SparkJob
	- WordCount
---

使用sparkJob 来进行WordCount处理
<!--more-->
# 编译环境搭建（Windows平台）

1、IDE环境Intellij 2017.2.2 ,首先安装好[Intellij IDEA](https://www.jetbrains.com/idea/)，和JAVA环境
2、在Intellij中安装scala插件
3、安装打包编译工具[sbt插件](http://www.scala-sbt.org/download.html)
4、配置.sbt源,在 C:\Users\Tiami\.sbt目录下新建repositories文件，文件写入如下内容
```
[repositories]
local
repox-maven: http://repox.gtan.com:8078
repox-ivy: http://repox.gtan.com:8078, [organization]/[module]/(scala_[scalaVersion]/)(sbt_[sbtVersion]/)[revision]/[type]s/[artifact](-[classifier]).[ext]
```

# WordCount-SparkJOb创建执行

## 1、新建立Scala-SBT项目
File-->New-->Project-->Scala-->SBT-->Next,输入项目名称，配置Java-JDK,选择SBT版本（勾选SBT后面的Source选项）
选择Scala版本,由于Spark的编译用到了Scala的依赖包，如果Scala版本选的比Spark编译的版本高将会报错。
对于spark2.2.0及以下的版本选择的Scala版本不应高于2.11.11


## 2、配置build.sbt
先配置build.sbt编译依赖文件，编辑build.sbt
```
name := "WordCount"
version := "1.0"
scalaVersion := "2.11.11"
// for spark
libraryDependencies += "org.apache.spark" %% "spark-core" % "2.1.1" % "provided"
libraryDependencies += "org.apache.spark" %% "spark-sql" % "2.1.1" % "provided"
```
## 3、新建Scala源文件
在项目的src/main/scala/下新建WordCount.Scala文件,加入如下内容
```
import org.apache.spark.sql.SparkSession
object WordCount{
  def main(args: Array[String]){
    val spark = SparkSession.builder().appName("WordCount").master("local").getOrCreate()
    val text = spark.sparkContext.textFile("file:///usr/hdp/2.6.1.0-129/spark2/README.md")
    val result=text.flatMap(_.split("[^A-Za-z]")).map((_,1)).reduceByKey(_+_).collect()
    result.foreach(println)
  }
}
```
## 4、编译配置
工具栏File-->Project Structure-->Artifacts-->+号新增-->JAR-->From module with dependencies-->OK
Create JAR from Modules-->Module:wordcount-->Main Class:WordCount-->OK
工具栏Build-->Build Artifacts-->wordcount.jar-->Build
编译结果在\out\artifacts\wordcount_jar\wordcount.jar


## 5、执行
将wordcount.jar，传入Hadoo-Spark集群环境spark-submit wordcount.jar执行



