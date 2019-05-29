#!/bin/bash

OS_check ( ) {
if [ -e /etc/redhat/-release ];then
   REDHAT=`cat /etc/redhat-release | cut -d' ' -f1`
else
   DEBIAN=`cat /etc/issue | cut -d' ' -f1`
fi

if [ "$REDHAT" == "CentOS" -o "$REDHAT" == "Red"];then
 P_M=yum
elif  [ "$DEBIAN" == "Ubuntn" -o "$DEBIAN" == "ubuntn"];then
 P_M=apt-get
else
 echo "no"
fi

}

if [ $LOGNAME != root ];then
   echo "please use the root account operation "
    exit 1
fi

if ! which vmstat &>/dev/null;then
   echo "vmstat command not found,now the in install"
   sleep 1
   OS_check
   $P_M install procps -y
fi

if ! which iostat &> /dev/null;then
 echo "vmstat command not found,now the in install"
   sleep 1
   OS_check
   $P_M install procps -y
fi

while true; do 
PS3="--->"
select input in cpu_load disk_load disk_use disk_inode mem_use tcp_status cpu_top10 mem_top10 traffic   quit; do

case $input in 
  cpu_load)
  echo "++++++++++++++++++"
  i=1
  while [[ $i -le 3 ]]; do
   echo -e "\033[32m 参考值${i}\033[0m"
   UTIL=`vmstat | awk '{if(NR==3)print 100-$15"%"}'`
   USER=`vmstat | awk '{if(NR==3)print $13"%"}'`
   SYS=`vmstat | awk '{if(NR==3)print $14"%"}'`
    IOWAIT=`vmstat | awk '{if(NR==3)print $16"%"}'`
   echo "Util:$UTIL"
   echo "User use:$USER"
   echo "System use:$SYS"
   echo "I/O wait:$IOWAIT"
   let  i++
   sleep 1
  done
  echo -e  "\e[31m++++++++++++++++++++\e[0m"
  break
  ;;
  disk_load)
 echo "+++++++++++++++++++++"
 i=1   
 while [[ $i -le 3 ]]; do
 echo -e "\033[32m 参考值${i}\033[0m"
  UTIL=`iostat -x -k | awk '/^[v|s]/{OFS=": ";print $1,$NF"%"}'`
  READ=`iostat -x -k | awk '/^[v|s]/{OFS=": ";print $1,$6"%"}'`
  WRITE=`iostat -x -k | awk '/^[v|s]/{OFS=": ";print $1,$7"%"}'`
  IOWAIT=`vmstat | awk 'NR==3 { print $16"%"}'`
 echo -e "Util:"
 echo -e "${UTIL}"
 echo -e "I/O Wait :$IOWAIT"
 echo -e "READ/s:\n$READ"
 echo -e "Write/s:\n$WRITE"
 i=$(($i+1))
 sleep 1
 done
 echo "+++++++++++++++++++++++"
 break
  ;;

 disk_use)
  #硬盘利用率
  DISK_LOG=/tmp/disk_use.tmp
  DISK_TOTAL=`fdisk -l |awk '/^Disk.*bytes/&&/\/dev/{printf $2" ";printf "%d",$3;print "GB"}'`
  USE_RATE=`df -h | awk '/^\/dev/{print int($5)}' `
  for i in $USE_RATE;do
       if [ $i -gt 90  ];then
          PART=`df -h | awk '{if (int($5)=='''$i''') print $6}'`
          echo "$PART = ${i}%" >> $DISK_LOG
       fi
   done
  echo -e " Disk total:\n ${DISK_TOTAL}"
  if [ -f $DISK_LOG ];then
   echo "----------------------------------"
    cat $DISK_LOG
  echo "---------------------------------"
 rm -f $DISK_LOG
 else 
   echo "----------------------------------"
   echo "Disk use rate no than 90% of the partition"
   echo "-----------------------------------"
 fi 
 break 
 ;;
 disk_inode)
 #硬盘inode利用文件源数据是存储在inode，任何一个满了都不行
 INODE_LOG=/tmp/inode_use.tmp 
 INODE_USE=`df -i | awk '/^\/dev/{print int($5)}'`
  for i in $INODE_USE;do
       if [ $i -gt 90  ];then
          PART=`df -h | awk '{if (int($5)=='''$i''') print $6}'`
          echo "$PART = ${i}%" >> $INODE_LOG
       fi
   done
  echo -e " INODE use :\n${INODE_USE}"
  if [ -f $INODE_LOG ];then
   echo "----------------------------------"
  cat $INODE_LOG
    echo "---------------------------------"
       rm -f $INODE_LOG
   else 
   echo "----------------------------------"
   echo "inode use rate no than 90% of the partition"
   echo "-----------------------------------"
 fi 
 break  
 ;;
 mem_use)
 #内存利用率
 echo "-------------------------------------"
 MEM_TOTAL=`free -m | awk '{if(NR==2) printf "%.1f",$2/1024}END{print "G"}'`
 USE=`free -m | awk '{if(NR==2) printf "%.1f",$3/1024}END{print "G"}'`
 FREE=`free -m | awk '{if(NR==2) printf "%.1f",$4/1024}END{print "G"}'`
 CACHE=`free -m | awk '{if(NR==2) printf "%.1f",$6/1024}END{print "G"}'`

 echo -e "Total : $MEM_TOTAL"
 echo -e "Use: $USE"
 echo -e "Free: $FREE"
 echo -e "Cache: $CACHE"
 echo "--------------------------------------"
 break
 ;;
 tcp_status)
 #网络来连接状态
 echo "--------------------------------------"
 COUNT=`ss -ant | awk '!/State/{status[$1]++}END{for (i in status) print i,status[i]}'`
 echo -e " TCP connection status: \n$COUNT"
  echo "----------------------------------------"
  ;;
 cpu_top10)
  #占用CPU高的前十个进程
  echo "---------------------------------------"
  CPU_LOG=/tmp/cpu_top.tmp
  i=1
  while [[ $i -le 3 ]]; do
   ps aux | awk '{if($3>0.1) {{ printf "PID: "$2" CPU: "$3"% -->"} for (i=11;i<=NF;i++) if(i==NF)printf $i"\n";else printf $i }}' | sort -k4 -nr | head -10 >$CPU_LOG
    if [[ -n `cat $CPU_LOG` ]];then
     echo -e "\e[32m 参考值 \e[0m"
      cat $CPU_LOG
      >$CPU_LOG
   else
     echo "NO process using the CPU"
     break
   fi
   let i++
   sleep 1
done
echo "-------------------------------------------------"
break
;;
 mem_top10)
 ##磁盘占用率前十
 MEM_LOG=/tmp/mem_top.tmp
 i=1
 while [[ $i -le 3 ]];do
 ps aux | awk '{if($4>0.1) {{ printf "PID: "$2" Memory: "$4"% -->"} for (i=11;i<=NF;i++) if(i==NF)printf $i"\n";else printf $i }}' | sort -k4 -nr | head -10 >$MEM_LOG
    if [[ -n `cat $MEM_LOG` ]];then
     echo -e "\e[32m 参考值 \e[0m"
      cat $MEM_LOG
      >$MEM_LOG
   else
     echo "NO process using the CPU"
     break
   fi
   let i++
   sleep 1
done
echo "-------------------------------------------------"
break
;;

traffic)
 #查看网络流量
  while true;do
  read -p " please enter the network card name (ens[0-9] or eth[0-9] or team[0-9])" eth
if [ `ifconfig | grep -c "\<$eth\>"` -eq 1 ];then
        break
 else
 echo "input format error or Don't have the card name."
fi
done
echo "--------------------------"
echo -e " In -------------------- Out"
i=1
while [[ $i -le 3 ]]; do
 ##CentOS6 输出输入流量的位置不同 
 #6 RX与 TX 等于8
 #7 RX与TX  4和6

 #以前接收
  OLD_IN=` ifconfig $eth | awk -F '[: ]+' '/bytes/{if(NR==8)print $4;else if(NR==4)print $6}'`
  OLD_OUT=` ifconfig $eth | awk -F '[: ]+' '/bytes/{if(NR==8)print $9;else if(NR==6)print $6}'`
   sleep 1
  NEW_IN=` ifconfig $eth | awk -F '[: ]+' '/bytes/{if(NR==8)print $4;else if(NR==4)print $6}'`
  NEW_OUT=` ifconfig $eth | awk -F '[: ]+' '/bytes/{if(NR==8)print $9;else if(NR==6)print $6}'`
  
  ##1M=1kbit  1kbit=8KB
  IN=`awk 'BEGIN{printf "%.1f\n",'$((${NEW_IN}-${OLD_IN}))'/1024/128}'`
  OUT=`awk 'BEGIN{printf "%.1f\n",'$((${NEW_OUT}-${OLD_OUT}))'/1024/128}'`
  echo "${IN}MB/s ${OUT}MB/s"
  i=$(($i+1))
  sleep 1
 done 
echo "-------------------------"
 break
;;

  quit)
  exit
  ;;
  *)
  echo "输入错误选项！！"
  
esac
done
done
