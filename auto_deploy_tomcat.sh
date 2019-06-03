#!/bin/env bash

#2019-06-03 10:10:10

#auto batch deploy tomcat

NUM=$1
TOMCAT_DIR=/usr/local

if [ -z $1 ];then
    echo -e "\033[32m --------------------- \033[0m"
    echo -e "\033[32m Usage: sh $0 1|2|3|10 \033[0m"
    exit 0
fi

VAR=`ls $TOMCAT_DIR/ |grep -c "tomcat*"`
if [ $VAR -eq 0 ];then
    yum -y install wget
    wget -c http://mirrors.yangxingzhen.com/jdk/jdk-8u144-linux-x64.gz
    tar xf jdk-8u144-linux-x64.gz
    mv jdk1.8.0_144 $TOMCAT_DIR

    cat >>/etc/profile <<EOF
export JAVA_HOME=/usr/local/jdk1.8.0_144
export CLASSPATH=\$CLASSPATH:\$JAVA_HOME/lib:\$JAVA_HOME/jre/lib
export PATH=\$JAVA_HOME/bin:\$JAVA_HOME/jre/bin:\$PATH:\$HOME/bin
EOF
    
    source /etc/profile
    wget -c http://mirrors.yangxingzhen.com/tomcat/apache-tomcat-8.0.48.tar.gz
    tar zxf apache-tomcat-8.0.48.tar.gz
    mv apache-tomcat-8.0.48 $TOMCAT_DIR/tomcat_1
    sed -i 's/8080/1001/g' $TOMCAT_DIR/tomcat_1/conf/server.xml
    sed -i 's/8005/2001/g' $TOMCAT_DIR/tomcat_1/conf/server.xml
    sed -i 's/8009/3001/g' $TOMCAT_DIR/tomcat_1/conf/server.xml
    
    exit 0
fi

NUM1=`ls $TOMCAT_DIR/ | grep "tomcat*" | awk -F_ '{print $NF}' | tail -1`
if [ -z $NUM1 ];then
    NUM1=0
fi

NUM2=`expr $NUM + $NUM1`
NUM3=`expr $NUM1 + 1`

for i in `seq $NUM3 $NUM2`
do
    PORT1=`expr 1001 + $i - 1`
    PORT2=`expr 2001 + $i - 1`
    PORT3=`expr 3001 + $i - 1`

    cp -a $TOMCAT_DIR/tomcat_1 $TOMCAT_DIR/tomcat_$i
    sed -i "s/1001/$PORT1/g" $TOMCAT_DIR/tomcat_$i/conf/server.xml
    sed -i "s/2001/$PORT2/g" $TOMCAT_DIR/tomcat_$i/conf/server.xml
    sed -i "s/3001/$PORT3/g" $TOMCAT_DIR/tomcat_$i/conf/server.xml
done
