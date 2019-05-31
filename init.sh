#!/bin/bash
#
#Autor:ZENG
#Date:2018/12/7
#



IP=`ip a|grep inet|grep brd|awk '{print $2}'|awk -F/ '{print $1}'`                       #得到机器IP
WD=`ip a|grep inet|grep brd|awk '{print $2}'|awk -F/ '{print $1}'|awk -F. '{print $2}'`  #得到机器网段



mkdir -pv /bak/initsys    #为接下来的文件做备份
cp /etc/selinux/config /bak/initsys/selinux.config
cp /etc/resolv.conf /bak/initsys/resolv.conf
cp /etc/security/limits.conf /bak/initsys/limits.conf
cp /etc/localtime /bak/initsys/localtime
cp /etc/sysconfig/clock /bak/initsys/clock
cp /etc/sysctl.conf /bak/initsys/sysctl.conf

#关闭防火墙，禁止开机启动
service iptables stop
chkconfig iptables off
sed -i 's@SELINUX=enforcing@SELINUX=disabled@g' /etc/selinux/config
setenforce 0

#根据网段做DNS解析和时间核对时区修改
if [ $WD == 18 ];then
cat > /etc/resolv.conf << EOF
nameserver 公网DNSIP
EOF
cat >> /etc/rc.local << EOF
/usr/sbin/ntpdate NTP_IP
hwclock -w
EOF
echo "*/5 * * * * /usr/sbin/ntpdate NTP_VIP" > /root/shijiancron
crontab -u root /root/shijiancron
rm -f /root/shijiancron

elif [ $WD == 17 ];then
cat > /etc/resolv.conf << EOF
nameserver 公网DNSIP
EOF
cat >> /etc/rc.local << EOF
/usr/sbin/ntpdate NTP_IP
hwclock -w
EOF
echo "*/5 * * * * /usr/sbin/ntpdate NTP_VIP" > /root/shijiancron
crontab -u root /root/shijiancron
rm -f /root/shijiancron
fi

rm -f /etc/localtime
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
cat > /etc/sysconfig/clock << EOF
ZONE="Asia/Shanghai"
UTC=false
ARC=false
EOF


##隐藏系统信息
echo "Welcome to Xe Server" > /etc/issue
echo "Welcome to Xe Server" > /etc/redhat-release

##更改文件打开数
cat >> /etc/security/limits.conf << EOF
*   soft   nofile   102400
*   hard   nofile   102400
*   soft   nproc    40960
*   hard   nproc    40960
EOF

##更改yum源为内网YUM
mkdir /etc/yum.repos.d/bak
mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/bak
cat > /etc/yum.repos.d/local.repo << EOF
[base]
name=1893baserepo
baseurl=自建yum源地址
gpgcheck=0
enabled=1
[zabbix]
name=1893zabbixrepo
baseurl=自建zabbix-yum源地址
gpgcheck=0
enabled=1
[epel]
name=1893epelrepo
baseurl=自建epel-yum源地址
gpgcheck=0
enabled=1
EOF
yum clean all

##设置系统字符集
cat >> /etc/profile <<EOF
export LC_ALL="zh_CN.UTF8"
export LANG="zh_CN.UTF8"
EOF
source /etc/profile

##安装常用软件
yum install -y screen cronolog

##同步其他初始化脚本，服务上线文件
mkdir -pv /cron/{restart,root}
同步其他初始化脚本
echo "/bin/bash /cron/restart/client.sh" >> /etc/rc.d/rc.local
init 6
