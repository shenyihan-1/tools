#!/usr/bin/bash
#Athour   tigerfive
ping -c1 www.baidu.com &>/dev/null
if [ $? -eq 0 ];then
	:
else
	echo "please check your internet "
	exit 
fi

core=`cat /etc/redhat-release |awk '{print $4}' |awk -F"." '{print $1}'`
baseyum=/etc/yum.repos.d/CentOS-Base.repo
epelyum=/etc/yum.repos.d/epel.repo

menu () {
case $core in
7)  curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
	curl -o /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo ;;
6) curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo 
        curl -o  /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-6.repo ;;
5) curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-5.repo
	curl -o /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-5.repo ;; 
esac
}


if [ -f "$baseyum" ];then
	mv $baseyum /etc/yum.repos.d/CentOS-Base.repo.bak && menu
else
	menu
fi


if [ $? -eq 0 ];then
	yum clean all && yum makecache
	echo "your yum is created sucesslly by Tigerfive"
else
	echo "installation failure"
fi
