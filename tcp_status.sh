#cat /etc/zabbix/zabbix_agentd.d/tcp.conf
#UserParameter=tcp_status[*],/bin/bash /etc/zabbix/scripts/tcp_status.sh "$1"
# cat /etc/zabbix/scripts/tcp_status.sh 
#!/bin/bash
#
#Autor:ZENG
#Date:2018/11/2
#

[ $# -ne 1 ] && echo "Usage:CLOSE-WAIT|CLOSED|CLOSING|ESTAB|FIN-WAIT-1|FIN-WAIT-2|LAST-ACK|LISTEN|SYN-RECV SYN-SENT|TIME-WAIT" && exit 1
tcp_status_fun(){
        TCP_STAT=$1
        #netstat -n | awk '/^tcp/ {++state[$NF]} END {for(key in state) print key,state[key]}' > /tmp/netstat.tmp
        ss -ant | awk 'NR>1 {++s[$1]} END {for(k in s) print k,s[k]}' > /tmp/ss.tmp
        TCP_STAT_VALUE=$(grep "$TCP_STAT" /tmp/ss.tmp | cut -d ' ' -f2)
        if [ -z $TCP_STAT_VALUE ];then
                TCP_STAT_VALUE=0
        fi
        echo $TCP_STAT_VALUE
}
tcp_status_fun $1
