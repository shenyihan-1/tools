#!/usr/bin/env bash
#
# Author: zeng
# Email: 
# Date: 2019/04/18
# Usage: init server computer.


# check user.
if [ $UID -eq 0 ];then
  echo "this user is root."
else
  id $USER | grep wheel
  if [ $? -eq 0 ];then
    echo "$USER is Admin."
  else
    echo "this user is not admin."
    exit
  fi
fi

# turn off firewalld and selinux.
sudo systemctl disable firewalld && sudo systemctl stop firewalld
STATUS=$(getenforce)
if [ $STATUS == "Disabled" ];then
  printf "SELINUX is closed.\n"
else
  sudo sed -ri s/SELINUX=enforcing/SELINUX=disabled/g /etc/selinux/config
  sudo setenforce 0
fi


# init yumrepo and install always software tools.
sudo mkdir /etc/yum.repos.d/repobak
sudo mv /etc/yum.repos.d/* /etc/yum.repos.d/repobak/

sudo curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
if [ $? -ne 0 ];then
  printf "Please check your network!!!\n"
  exit
else
  sudo curl -o /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
  if [ $? -ne 0 ];then
    printf "Please check your network!!!\n"
    exit
  else
    sudo sed -rie '/aliyuncs*/d' /etc/yum.repos.d/CentOS-Base.repo
    sudo yum clean all && sudo yum makecache fast
  fi
fi

sudo yum -y install vim net-tools wget ntpdate ShellCheck cmake make lftp
sudo yum -y groupinstall "Development Tools"


# time upload rsync.
sudo ntpdate -b ntp1.aliyun.com

# sshd majorization.
sudo sed -ri s/"#UseDNS yes"/"UseDNS no"/g /etc/ssh/sshd_config
sudo systemctl restart sshd

# configure network config file.
sudo cp /etc/sysconfig/network-scripts/ifcfg-$(ifconfig | awk -F":" 'NR==1{ print $1 }'){,.bak}
sudo sed -ri '/IPV6*/d' /etc/sysconfig/network-scripts/ifcfg-$(ifconfig | awk -F":" 'NR==1{ print $1 }')
sudo systemctl restart network

