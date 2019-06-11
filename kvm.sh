#!/usr/bin/bash
#Athour :tigerfive
#v0.3.20
images_dir=/var/lib/libvirt/images
xml_dir=/etc/libvirt/qemu

uuid_mac() {
uuid_based_mac=`uuidgen`
vm_mac="52:54:$(dd if=/dev/urandom count=1 2>/dev/null | md5sum | sed -r 's/^(..)(..)(..)(..).*$/\1:\2:\3:\4/')"
}

help(){
cat <<EOF
		+------------------------------------------------------+
		|    虚拟机基础管理-------------tigerfive	       |
		|            1.安装kvm				       |
		|            2.安装或者重置centos-7.3		       |
		|	     3.删除所有虚拟机			       |
		|	     4.打开虚拟机			       |
		|	     5.关闭虚拟机			       |
		|	     6.克隆虚拟机			       |
		|	     q.退出管理程序			       |
		|	     h.查看帮助				       |
		+------------------------------------------------------+
EOF
}

net_check(){
	ping -c1 www.baidu.com  &>/dev/null	
	
	if [ $? -eq 0 ];then
	echo "net is up"
	else 
	echo "please check you net,l can't download data!"
	exit 1
	fi

}

yum_check(){
	yum_list=`yum repolist | grep "repolist:" | awk  '{print $2}'`
	yum_line=`echo "$yum_list" | wc -c`
	if [ $yum_line -gt 4 ];then
	:
	else
		echo "yum not used! you can use other script "yum-creat-net" by tigerfive"
		exit 1
	fi
}

check_209(){
	ping -c1 10.18.44.114  &>/dev/null
	rc=$?
	if [ $rc -eq 0 ];then
		:
	else
		echo "l can't link 114 ,please call tigerfive"
		exit 1
	fi
}

virsh_list(){
	list=(`virsh list --all  | grep " centos*"  | awk  '{print $2}'`)
	list1=(`virsh list --all  | grep " centos*"  | awk  '{print $3}'`)
	num=`echo ${#list[@]}`
		for i in `seq  $num`
		do	
			a=$(($i-1))
			echo "你的第 $i 台虚拟机名字是： ${list[a]}  状态为： ${list1[a]}" 	
		done
}

	

while true
do
	help
	read -p "请输入选项： " change
	#install kvm-manger

    	case $change in 
	
	1)  
		rpm -qa virt-manager  &>/dev/null
		if [ $? -eq 0 ];then
		net_check
		yum_check
		echo "开始安装kvm"
		sleep 1
		echo "正在安装"
			yum -y install *virt* *qemu* *kvm*  
		systemctl start virt-manger || systemctl start libvirtd
		systemctl enable virt-manger || systemctl enable libvirtd
			if [ $? -eq 0 ];then
			echo "============"
			echo "安装完成 ，已经启动"
			echo "============"
			fi
		fi
	;;

	2)	
		net_check
		yum_check
#		check_209
		read -p "是否要安装5台centos7u3的虚拟机[Y/N]"  choose
		if [ $choose == "Y" ];then
	
#			wget -O $images_dir/centos7u3_base.qcow2   ftp://10.3.145.114/kvm/centos7u3_base.qcow2
			wget -O $xml_dir/centos7u3_base.xml   ftp://10.3.145.114/kvm/centos7u3_base.xml
			for i in {1..5}
			do	
				cp $xml_dir/centos7u3_base.xml  $xml_dir/centos7u3_$i.xml
                                uuid_mac
				vm_name=centos7u3_$i
				vm_uuid=`uuidgen`
				vm_disk=centos7u3_$i.qcow2
                                vm_mac="52:54:$(dd if=/dev/urandom count=1 2>/dev/null | md5sum | sed -r 's/^(..)(..)(..)(..).*$/\1:\2:\3:\4/')"
				sed -i 's/VM_NAME/'${vm_name}'/'   $xml_dir/centos7u3_$i.xml
				sed -i 's/VM_UUID/'${vm_uuid}'/'   $xml_dir/centos7u3_$i.xml
				sed -i 's/VM_DISK/'${vm_disk}'/'   $xml_dir/centos7u3_$i.xml
				sed -i 's/VM_MAC/'${vm_mac}'/'   $xml_dir/centos7u3_$i.xml
			
				cp $images_dir/centos7u3_base.qcow2  $images_dir/centos7u3_$i.qcow2
				virsh define $xml_dir/centos7u3_${i}.xml
	
			done
		
		else
		exit
		fi
	;;
	
	3)
		rm -rf  $xml_dir/*.xml
		rm -rf  $images_dir/*..qcow2
	
	;;
	
	4)
		# "打开虚拟机"
			

		list=(`virsh list --all  | grep " centos*"  | awk  '{print $2}'`)
		list1=(`virsh list --all  | grep " centos*"  | awk  '{print $3}'`)
		num=`echo ${#list[@]}`
                for i in `seq  $num`
                do
                        a=$(($i-1))
                        echo "你的第 $i 台虚拟机名字是： ${list[a]}  状态为： ${list1[a]}"      
                done
	
		read -p "请选择你要打开的虚拟机" open
		#until [	$# -eq 0 ]
		#do
		#virsh start ${list[a]}
		#shift
		#done	
		b=$(($open-1))
	#	virt-manger
		virsh start ${list[b]}
		
		wait
		virsh_list
		read -p "已经打开虚拟机，是否继续" jixu
		continue
	;;

	5)
		#	echo "关闭虚拟机"
		virsh list --all
                list=(`virsh list --all  | grep " centos*"  | awk  '{print $2}'`)
                list1=(`virsh list --all  | grep " centos*"  | awk  '{print $3}'`)
                num=`echo ${#list[@]}`
                for i in `seq  $num`
                do
                        a=$(($i-1))
                        echo "你的第 $i 台虚拟机名字是： ${list[a]}  状态为： ${list1[a]}"      
                done

                read -p "请选择你要关闭的虚拟机" close

                b=$(($close-1))
                virt-manger
                virsh shutdown ${list[b]}

                wait
                #virsh list --all
                sleep 2
                virsh list

	
	;;

	6)
        	#        echo "克隆虚拟机"
                virsh list --all
                list=(`virsh list --all  | grep " centos*"  | awk  '{print $2}'`)
                list1=(`virsh list --all  | grep " centos*"  | awk  '{print $3}'`)
                num=`echo ${#list[@]}`
                for i in `seq  $num`
                do
                        a=$(($i-1))
                        echo "你的第 $i 台虚拟机名字是： ${list[a]}  状态为： ${list1[a]}"      
                done

                read -p "请选择你要克隆的虚拟机" clone

                c=$(($clone-1))
                clone_name=${list[c]}
                cp $xml_dir/centos7u3_base.xml  $xml_dir/$clone_name-clone.xml
                                vm_name=$clone_name-clone
                                vm_uuid=$uuid_base$c$clone
                                vm_disk=$clone_name-clone.qcow2
                                sed -i 's/VM_NAME/'${vm_name}'/'   $xml_dir/$clone_name-clone.xml
                                sed -i 's/VM_UUID/'${vm_uuid}'/'   $xml_dir/$clone_name-clone.xml
                                sed -i 's/VM_DISK/'${vm_disk}'/'   $xml_dir/$clone_name-clone.xml
                                sed -i 's/VM_MAC/'${vm_mac}'/'     $xml_dir/$clone_name-clone.xml

                                cp $images_dir/centos7u3_base.qcow2  $images_dir/$clone_name.qcow2
                                virsh define $xml_dir/$vm_name.xml

	;;
	q)
		exit
	;;	
	
	h)	
		:	
	;;

	*)
		echo "无效的选择，请重新输入"
	;;
	esac


done

