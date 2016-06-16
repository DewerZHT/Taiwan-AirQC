-----
author: 吳振豪 Wu, Chen-Hao
date: 2016.06.14
fielname: hadoop-build-up.md
-----

# hadoop build-up log
## Step List
1. 
2. 
3. 
4. 

## Step 01
install fedora 23 Server x64
open ssh service
check firewall service (nmap tool)

## Step 03
configuration host name
# vim /etc/hosts
add thte following to bottom
192.168.1.213 master
192.168.1.97  slave01
192.168.1.233 slave02

## Step 04
create hadoop user in all VM
# useradd hadoop
# passwd hadoop

## Step 05
SSH config for user hadoop at all VM
master can login slave01 & slave02
slave01 & slave02 can login master
hadoop@master
change user to hadoop
# su - hadoop
generating rsa-key-pair
$ ssh-keygen -t rsa -P '' -f ~/.ssh/id_dsa
$ cat ~/.ssh/id_dsa.pub >> ~/.ssh/authorized_keys
$ chmod 600 ~/.ssh/authorized_keys
$ ll
-rw-------. 1 hadoop hadoop  395 Jun 15 18:57 authorized_keys
-rw-------. 1 hadoop hadoop 1679 Jun 15 18:56 id_dsa
-rw-r--r--. 1 hadoop hadoop  395 Jun 15 18:56 id_dsa.pub
change back to root
$ su
# vim /etc/ssh/sshd_config
修改 following
RSAAuthentication yes
PubkeyAuthentication yes
# systemctl restart sshd
# su - hadoop
$ ssh master
[hadoop@master ~]$ exit
logout
# scp /home/hadoop/.ssh/authorized_keys hadoop@slave01:/home/hadoop/.ssh/authorized_keys_master
# scp /home/hadoop/.ssh/authorized_keys hadoop@slave02:/home/hadoop/.ssh/authorized_keys_master

switch to root@slave01
# cat /home/hadoop/.ssh/authorized_keys_master01 >> /home/hadoop/.ssh/authorized_keys

switch back to hadoop@master
# ssh slave01
# exit

switch to root@slave02
# cat /home/hadoop/.ssh/authorized_keys_master01 >> /home/hadoop/.ssh/authorized_keys

switch back to hadoop@master
# ssh slave01
# exit

rm public key files
switch to root@slave01

## Step 02
do this with root
check hadoop version and it's tested JDK version
http://wiki.apache.org/hadoop/HadoopJavaVersions
install them
use sFTP transfer installation file
```
Note that: switch cwd to jdk rpm package location
# rpm -Uvh jdk-7u45-linux-x64.rpm 

# java -version
java version "1.7.0_45"
Java(TM) SE Runtime Environment (build 1.7.0_45-b18)
Java HotSpot(TM) 64-Bit Server VM (build 24.45-b08, mixed mode)
# javac -version
javac 1.7.0_45

Switch to hadoop user
add followign to .bashrc file
export JAVA_HOME=/usr/java/jdk1.7.0_45

# echo $JAVA_HOME 
/usr/java/jdk1.7.0_45
```

## Step 06
download hadoop2.7.1 and extract
root@master
# wget http://apache.stu.edu.tw/hadoop/common/hadoop-2.7.1/hadoop-2.7.1.tar.gz
# tar -zxvf hadoop-2.7.1.tar.gz
delete the download tar file
# rm hadoop-2.7.1.tar.gz
move hadoop2.7.1 dir to /usr/local
# mv hadoop-2.7.1 /usr/local

## Step 07
Configure hadoop cluster
switch cwd to /usr/local
# cd /usr/local
change owner of hadoop dir to hadoop user
# chown -R hadoop:hadoop hadoop-2.7.1
Setup environment path
Switch user to hadoop
add followign to .bashrc file
export HADOOP_HOME=/usr/local/hadoop-2.7.1
export HADOOP_MAPRED_HOME=$HADOOP_HOME
export HADOOP_COMMON_HOME=$HADOOP_HOME
export HADOOP_HDFS_HOME=$HADOOP_HOME
export YARN_HOME=$HADOOP_HOME
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
export YARN_CONF_DIR=$HADOOP_HOME/etc/hadoop
export PATH=$PATH:$HADOOP_HOME/bin
export PATH=$PATH:$HADOOP_HOME/sbin
echo $PATH
/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/hadoop/.local/bin:/home/hadoop/bin:/usr/local/hadoop-2.7.1/bin:/usr/local/hadoop-2.7.1/sbin
# hadoop version
Hadoop 2.7.1
Subversion https://git-wip-us.apache.org/repos/asf/hadoop.git -r 15ecc87ccf4a0228f35af08fc56de536e6ce657a
Compiled by jenkins on 2015-06-29T06:04Z
Compiled with protoc 2.5.0
From source with checksum fc0a1a23fc1868e4d5ee7fa2b28a58a
This command was run using /usr/local/hadoop-2.7.1/share/hadoop/common/hadoop-common-2.7.1.jar

Checke disk volumn
# df
decied to create a tmp dir in /home/hadoop/
for hadoop hdfs to store data
/home/hadoop/tmp

### config core-site.xml
# vim ${HADOOP_CONF_DIR}/core-site.xml
between <configuration> tag
<property>
  <name>fs.default.name</name>
  <value>hdfs://master:9000</value>
</property>  
<property>
  <name>hadoop.tmp.dir</name>
  <value>/home/hadoop/tmp</value>
</property>

### config hdfs-site.xml
# vim ${HADOOP_CONF_DIR}/hdfs-site.xml
between <configuration> tag
<property>
  <name>dfs.replication</name>
  <value>3</value>
</property>
<property>
  <name>dfs.permissions</name>
  <value>false</value>
</property>

### config mapred-site.xml
# vim ${HADOOP_CONF_DIR}/mapred-site.xml
between <configuration> tag
<property>
  <name>mapreduce.framework.name</name>
  <value>yarn</value>
</property>

### config yarn-site.xml
# vim ${HADOOP_CONF_DIR}/yarn-site.xml
between <configuration> tag
<property>
  <name>yarn.resourcemanager.resource-tracker.address</name>
  <value>master:8031</value>
</property>
<property>
  <name>yarn.resourcemanager.scheduler.address</name>
  <value>master:8030</value>
</property>
<property>
  <name>yarn.resourcemanager.scheduler.class</name>
  <value>org.apache.hadoop.yarn.server.resourcemanager.scheduler.capacity.CapacityScheduler</value>
</property>
<property>
  <name>yarn.resourcemanager.address</name>
  <value>master:8032</value>
</property>
<property>
  <name>yarn.nodemanager.local-dirs</name>
  <value>${hadoop.tmp.dir}/nodemanager/local</value>
</property>
<property>
  <name>yarn.nodemanager.address</name>
  <value>0.0.0.0:8034</value>
</property>
<property>
  <name>yarn.nodemanager.remote-app-log-dir</name>
  <value>${hadoop.tmp.dir}/nodemanager/remote</value>
</property>
<property>
  <name>yarn.nodemanager.log-dirs</name>
  <value>${hadoop.tmp.dir}/nodemanager/logs</value>
</property>
<property>
  <name>yarn.nodemanager.aux-services</name>
  <value>mapreduce_shuffle</value>
</property>
<property>
  <name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>
  <value>org.apache.hadoop.mapred.ShuffleHandler</value>
</property>

## Step 08
send master configed file to all slaves
# cd /usr/local
# scp -r hadoop-2.7.1 slave01:/usr/local/
# scp -r hadoop-2.7.1 slave02:/usr/local/

## Step 09
format namenode
# hadoop namenode -format

## Step 10
start all hadoop service
in hadoop user
# start-all.sh
This script is Deprecated. Instead use start-dfs.sh and start-yarn.sh
Starting namenodes on [master]
master: starting namenode, logging to /usr/local/hadoop-2.7.1/logs/hadoop-hadoop-namenode-master.out
slave01: starting datanode, logging to /usr/local/hadoop-2.7.1/logs/hadoop-hadoop-datanode-slave01.out
slave02: starting datanode, logging to /usr/local/hadoop-2.7.1/logs/hadoop-hadoop-datanode-slave02.out
Starting secondary namenodes [0.0.0.0]
0.0.0.0: starting secondarynamenode, logging to /usr/local/hadoop-2.7.1/logs/hadoop-hadoop-secondarynamenode-master.out
starting yarn daemons
starting resourcemanager, logging to /usr/local/hadoop-2.7.1/logs/yarn-hadoop-resourcemanager-master.out
slave01: starting nodemanager, logging to /usr/local/hadoop-2.7.1/logs/yarn-hadoop-nodemanager-slave01.out
slave02: starting nodemanager, logging to /usr/local/hadoop-2.7.1/logs/yarn-hadoop-nodemanager-slave02.out

## Step 11
check hadoop service state
# jps
