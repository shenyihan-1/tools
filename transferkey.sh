#!/usr/bin/env bash
#
# Author: zeng
# Email: 
# Date: 2019/04/18
# Usage: tranfer ssh-key to remote computer server.

# create ssh-key.
CreateKey() {
/usr/bin/expect <<-ROF
spawn ssh-keygen
expect ":" { send "\r" }
expect ":" { send "\r" }
expect ":" { send "\r" }
expect eof
ROF
}

TransferKey() {
/usr/bin/expect <<-ROF
spawn ssh-copy-id $user@$ip
expect "yes/no*" { send "yes\r" }
expect "password:" { send "$passwd\r" }
expect eof
ROF
}

Information() {
  read -p "Please input username: " user
  read -p "Please input ipaddress: " ip
  read -p "Please input Pasword: " passwd

}

sudo yum -y install expect
if [ $? -eq 0 ];then
  if [ -f $HOME/.ssh/id_rsa ];then
    Information
    TransferKey
  else
    CreateKey
    Information
    TransferKey
  fi
fi
