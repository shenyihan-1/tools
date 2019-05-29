#!/bin/bash
DATE=$(date +%F" "%H:%M)
IP=$(ip a | awk -F" " 'NR==9 { print $2 }' | cut -c 1-12)
MATL="example@mail.com"
if ! which vmstat &>/dev/null;then
 echo "vmstat command no found,please install procps package"
 exit 1
fi
US=$(vmstat | awk 'NR==3 {print $13}')
SY=$(vmstat | awk 'NR==3 {print $14}')
IDLE=$(vmstat | awk 'NR==3 {print $15}')
WAIT=$(vmstat | awk 'NR==3 {print $16}')
USE=$(($US+$SY))
if [ $USE -ge 50 ];then
echo "
Date: $DATE
HOST: $IP
Problem: CPU utilitzaion $USE " | mail -s "CPU Monitor " $MATL
fi
