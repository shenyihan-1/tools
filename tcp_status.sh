#!/usr/bin/env bash
LISTEN ( ) {
 ss -an | grep '^tcp' | grep "LISTEN" | wc -l
 }
##连接状态 SYN请求连接 FIN关闭
ESTABLISHED ( ) {
          ss -an | grep '^tcp' | grep 'SYN[_-]RECV' | wc -l
}
ESTABLISHED ( ){
          ss -an | grep '^tcp' | grep 'ESTAB' | wc -l
}
TIME_WAIT ( ) {
          ss -an | grep '^tcp' | grep 'TIME[_-]WAIT' | wc -l
}
$1

