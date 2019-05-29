#!/bin/bash
cat > /etc/sysconfig/network-scripts/ifcfg-ens33 <<EOF
TYPE=Ethernet
DEVICE=ens33
ONBOOT=yes
BOOTPROTO=static
IPADDR=10.3.145.$1
PREFIX=24
GATEWAY=10.3.145.1
DNS1=114.114.114.114
EOF
if [ $? -eq 0 ];then
        ifdown ens33;ifup ens33;
fi
~      
