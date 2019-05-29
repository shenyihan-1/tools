#!/bin/bash
DATE=$(date +%F" "%H:%M)
IP=$(ip a | awk -F" " 'NR==9 { print $2 }' | cut -c 1-12)
MATL="example@mail.com"
TOTAL=$( free -m | awk '/Mem/{print $2}')
FREE=$( free -m | awk '/Mem/{print $3-$6-$7}')
FREE=$(($TOTAL-$USE))
if [ $FREE -lt 1024 ];then
echo " 
Date:$DATE
Host:$IP
Problem: Total=$TOTAL,Use=$USE,Free=$FREE " | mail -S "memory monitor" $MAIL
fi
