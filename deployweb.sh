#!/usr/bin/env bash
#
# Author: zeng
# Email: 
# Date: 2019/04/18
# Usage: install nginx web service.


# deploy nginx web service action on install before.
sudo yum -y install pcre-devel zlib-devel openssl-devel
sudo yum -y groupinstall "Development Tools"

sudo groupadd -g 996 nginx
sudo useradd -M -s /sbin/nologin -g nginx -u 998 nginx

wget https://nginx.org/download/nginx-1.14.2.tar.gz

# install nginx web service.
sudo tar xf nginx-1.14.2.tar.gz -C /opt/
cd /opt/nginx-1.14.2/
sudo ./configure --prefix=/usr/local/nginx/ --sbin-path=/usr/local/nginx/sbin/nginx --conf-path=/usr/local/nginx/conf/nginx.conf --error-log-path=/usr/local/nginx/logs/error.log --user=nginx --group=nginx --with-threads --with-http_ssl_module --with-debug
if [ $? -eq 0 ];then
  sudo make && sudo make install
else
  printf "your installtion failed!!!\n"
fi

# configure enviorment path.
echo "export PATH=/usr/local/nginx/sbin:\$PATH" >>/etc/profile
source /etc/profile
