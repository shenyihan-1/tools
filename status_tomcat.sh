#!/usr/bin/bash
#
#Autor:ZENG
#Date:2018/3/2


TOMCAT_HOME="/usr/local"
SUM=` ls $TOMCAT_HOME | grep "tomcat*" | awk -F_ '{print $NF}'| tail -1`

start( ){
for i in `seq  1 $SUM`
do
STATUS=`ss -tunlp | grep  "100$i"| awk '{print $5}'|cut -c 7 `
if [ -z  $STATUS ];then
	$TOMCAT_HOME/tomcat_$i/bin/startup.sh 
        echo -e "\e[32m tomcat_$i 已启动!！\e[0m"
   else
       echo "tomcat_$i 已存在！"
fi
done
}

stop( ){
for i in `seq  1 $SUM`
do
STATUS=`ss -tunlp | grep  "100$i"| awk '{print $5}'|cut -c 7 `
if [ -z  $STATUS ];then 
     echo -e "\e[32m tomcat_$i 已关闭!！\e[0m"
   else
    $TOMCAT_HOME/tomcat_$i/bin/shutdown.sh
     echo -e "\e[31m tomcat_$i 已关闭！\e[0m"
fi
done

}

$1
