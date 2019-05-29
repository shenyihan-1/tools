#!/usr/bin/bsah
#
#Autor:ZENG
#Date:2019/4/23
#usage: check ip alive sown
>ip.down.txt
>ip.alive.txt

read -p "输入所在网段：" network

for i in {2..254}
do
{
ping -c1 $network.$i &>/dev/null

if [ $? -eq 0 ];then
echo "$network.$i" >>ip.alive.txt
else
echo "$network.$i" >>ip.down.txt
fi
} &
done

wait
~  
