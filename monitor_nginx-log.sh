#!/bin/bash
#
#Autor:ZENG
#Date:2018/3/12
#usage: moniter nginx log

while : 
do
cat <<-EOF
+-------------------------------------------------------------------------+
+                      nginx日志监控                                      +                  
+                  1、某天 PV量                                           +
+                  2、某时间段 PV量                                       +
+                  3、前某段时间 PV量                                     +
+                  4、ip访问量 top10                                      +
+                  5、url访问量 top10                                     +
+                  6、访问状态情况统计                                    +
+                  7、查找访问超过指定次数ip                              +
+                  8、退出！                                              +
+-------------------------------------------------------------------------+
EOF
echo -e  "\e[32m请输入选项：\e[0m" && read i
case $i in
1)
read -p "请输入日志文件:" LOG
#read -p "输入查找日期,格式为'05/sep/2018'" DATE
cat $LOG | wc -l
;;
2)
read -p "请输入日志文件:" LOG
read -p "输入查找时间段前,格式为'[24/May/2019:01:00:00'" BEFORE
read -p "输入查找时间段后,格式为'[24/May/2019:01:00:00'" AFTER
cat $LOG | awk -v before="$BEFORE" -v  after="$AFTER" -F" " '$4>="before"&&$4<="after"{print $1}' | wc -l
;;
3)
read -p "请输入日志文件:" LOG
read -p "输入查找数字：" DATE1
read -p "输入单位minute hour day week： " UNIT 
date1=$(date -d ' -'''$DATE1''' '''$UNIT''' ' +%d/%b/%Y:%H:%M)
awk -v date=$date1 '$0 ~ date {i++}END {print i}' $LOG
;;
4)
read -p "请输入日志文件:" LOG
#read -p "输入查找日期,格式为'05/sep/2018':" DATE
  awk '{ips[$1]++} END{for(i in ips ){print i,ips[i]}} ' $LOG | sort -k2 -rn | head -n10
;;
5)
read -p "请输入日志文件:" LOG
#read -p "输入查找日期,格式为'05/sep/2018':" DATE
cat $LOG | awk '{ips[$7]++} END{for(i in ips ){print i,ips[i]}} ' | sort -k2 -rn | head -n10
;;
6)
read -p "请输入日志文件:" LOG
awk '{code[$9]++;total++}END{for (i in code){printf i " ";printf code[i]"\t";printf "%.2f",code[i]/total*100;print "%"}}' $LOG
;;
7)
read -p "请输入日志文件:" LOG
#read -p "输入查找日期,格式为'05/sep/2018':" DATE
read -p "输入限定次数：" NUM
cat  $LOG | awk -v num=$NUM '{ips[$1]++} END{ for(i in ips ){ if(ips[i]>num) {print i,ips[i]} } } ' | sort -k2 -rn | head -n10
;;
8)
break
;;
*)
echo -e "\e[31m请输入数字！\e[0m"
;;
esac
done
