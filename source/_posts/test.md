---
title: test git 
date: 2017-08-20 12:50:38
category:  
	- test
	- Spark
tags: 
	- test
	- test
---
使用spark-shell 来进行WordCount处理 

<!--more-->

# [WordCounter](https://wordcounter.net/)
实现文本的单词计数统计，测试文件为spark2的README.Md文档  
# 寻找spark2的README.md文件所在位置  
find / -name 'README.md'  
如文件位置/usr/hdp/2.6.1.0-129/spark2/README.md  

# 启动spark-shell，使用spark-shell 来进行统计  
```
Spark-shell
# 从本地读取文件
scala> val textFile=sc.textFile("file:///usr/hdp/2.6.1.0-129/spark2/README.md")
# 按Key升序排序
scala> val wordCount = textFile.flatMap(line => line.split("[^A-Za-z]")).map(word => (word, 1)).reduceByKey((a, b) => a + b).sortByKey().collect
scala> val wordCount = textFile.flatMap(_.split("[^A-Za-z]")).map((_,1)).reduceByKey(_ + _).sortByKey().collect
# 按Key降序排序
scala> val wordCount = textFile.flatMap(line => line.split("[^A-Za-z]")).map(word => (word, 1)).reduceByKey((a, b) => a + b).sortByKey(false).collect
scala> val wordCount = textFile.flatMap(_.split("[^A-Za-z]")).map((_, 1)).reduceByKey(_ + _).sortByKey(false).collect
# 按Value升序排序
val wordCount = textFile.flatMap(line => line.split("[^A-Za-z]")).map(word => (word, 1)).reduceByKey((a, b) => a + b).map(x=>(x._2,x._1)).sortByKey().map(x=>(x._2,x._1)).collect
val wordCount = textFile.flatMap(_.split("[^A-Za-z]")).map((_, 1)).reduceByKey(_ + _).map(x=>(x._2,x._1)).sortByKey().map(x=>(x._2,x._1)).collect
# 按Value降序排序
val wordCount = textFile.flatMap(line => line.split("[^A-Za-z]")).map(word => (word, 1)).reduceByKey((a, b) => a + b).map(x=>(x._2,x._1)).sortByKey(false).map(x=>(x._2,x._1)).collect
val wordCount = textFile.flatMap(_.split("[^A-Za-z]")).map((_, 1)).reduceByKey(_ + _).map(x=>(x._2,x._1)).sortByKey(false).map(x=>(x._2,x._1)).collect
```


---  

# 小结
1、启动spark-shell时，会创建一个名为sc的sparkContext
```
#启动示例
./bin/spark-shell --master local[4]
./bin/spark-shell --master local[4] --jars code.jar
./bin/spark-shell --master local[4] --packages "org.example:example:0.1"
```
2、使用sparkContext加载文件方式
```
# 从本地系统读取文件
val textFile=sc.textFile("file:///usr/hdp/2.6.1.0-129/spark2/README.md")
# 从HDFS上读取文件
# 可使用 hdfs dfs -put /usr/hdp/2.6.1.0-129/spark2/README.md /user/spark2/README.md 将文件从本地传入HDFS
val textFile=sc.textFile("/user/spark2/README.md")
```
3、函数说明
flatMap() 						:相当于将多个集合中的元素先提取出来，之后组成一个集合（元素不去重）
line => line.split("[^A-Za-z]")	:对于文件的每一行，按正则表达式[^A-Za-z]进行拆分，即按非字母字符拆分
map(word => (word, 1))			:将单个的元素RDD[String],通过map变换成key-value二元组RDD[(String, Int)]
collect 						:触犯Actor,并显示处理结果

3、写为一行 
``` 
sc.textFile("file:///usr/hdp/2.6.1.0-129/spark2/README.md").flatMap(_.split("[^A-Za-z]")).map((_, 1)).reduceByKey(_ + _).map(x=>(x._2,x._1)).sortByKey(false).map(x=>(x._2,x._1)).collect
```


