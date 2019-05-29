#!/bin/bash
PS3=">"
select choice in disk_partition filesystem cpu_load mem_uitl quit
do
case "$choice" in
   disk_partition)
   fdisk -l
   ;;
   filesystem)
   df -Th
   ;;
   cpu_load)
   uptime
   ;;
   mem_uitl)
   free -m
   ;;
   quit)
   break
esac
done
