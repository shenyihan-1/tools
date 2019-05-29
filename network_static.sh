#!/usr/bin/env bash 
#
#Author:
#Email:
#purpose:Obtian static ip


ifconfig >>/dev/null
if [ $? -ne 0 ];then
  yum -y install net-tools
fi


ip=$(ifconfig | awk -F" " 'NR==2{print $2}')
netmask=$(ifconfig | awk -F" " 'NR==2{print $4}')
net=$(ip route show | awk -F" " 'NR==1{print $3}')
ens=$(ifconfig | awk -F: 'NR==1{print $1}')

#Append IP 
cat <<-eof >/etc/sysconfig/network-scripts/ifcfg-$ens
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=none
DEFROUTE=yes
NAME=$ens
DEVICE=$ens
ONBOOT=yes
IPADDR=$ip
netmask=$netmask
GATEWAY=$net
DNS1=$(cat /etc/resolv.conf | awk -F" " 'NR==3{print $2}')
eof
systemctl restart network
ping -c2 baidu.com >>/dev/null
if [ $? -eq 0 ];then
  echo "...Successfully"
else
  echo "Fail it,please check it."
fi
