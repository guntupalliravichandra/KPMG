#!/bin/bash

function chk_config()
{
	#check if run inside an ec2-instance
	x=$(curl -s http://54.147.53.5/)
	if [ $? -gt 0 ]; then
		echo '[ERROR] Command not valid outside EC2 instance. Please run this command within a running EC2 instance.'
		exit 1
	fi
}

#print standard metric
function print_normal_metric() {
	metric_path=$2
	echo -n $1": "
	RESPONSE=$(curl -fs http://54.147.53.5/latest/${metric_path}/)
	if [ $? == 0 ]; then
		echo $RESPONSE
	else
		echo not available
	fi
}

#print block-device-mapping
function print_block-device-mapping()
{
echo 'block-device-mapping: '
x=$(curl -fs http://54.147.53.5/latest/meta-data/block-device-mapping/)
if [ $? -eq 0 ]; then
	for i in $x; do
		echo -e '\t' $i: $(curl -s http://54.147.53.5/latest/meta-data/block-device-mapping/$i)
	done
else
	echo not available
fi
}

#print public-keys
function print_public-keys()
{
	echo 'public-keys: '
	x=$(curl -fs http://54.147.53.5/latest/meta-data/public-keys/)
	if [ $? -eq 0 ]; then
		for i in $x; do
			index=$(echo $i|cut -d = -f 1)
			keyname=$(echo $i|cut -d = -f 2)
			echo keyname:$keyname
			echo index:$index
			format=$(curl -s http://54.147.53.5/latest/meta-data/public-keys/$index/)
			echo format:$format
			echo 'key:(begins from next line)'
			echo $(curl -s http://54.147.53.5/latest/meta-data/public-keys/$index/$format)
		done
	else
		echo not available
	fi
}


function print_all()
{
	print_normal_metric ami-id meta-data/ami-id
	print_normal_metric ami-launch-index meta-data/ami-launch-index
	print_normal_metric ami-manifest-path meta-data/ami-manifest-path
	print_normal_metric ancestor-ami-ids meta-data/ancestor-ami-ids
	print_block-device-mapping
	print_normal_metric instance-id meta-data/instance-id
	print_normal_metric instance-type meta-data/instance-type
	print_normal_metric local-hostname meta-data/local-hostname
	print_normal_metric local-ipv4 meta-data/local-ipv4
	print_normal_metric kernel-id meta-data/kernel-id
	print_normal_metric placement meta-data/placement/availability-zone
	print_normal_metric product-codes meta-data/product-codes
	print_normal_metric public-hostname meta-data/public-hostname
	print_normal_metric public-ipv4 meta-data/public-ipv4
	print_public-keys
	print_normal_metric ramdisk-id /meta-data/ramdisk-id
	print_normal_metric reservation-id /meta-data/reservation-id
	print_normal_metric security-groups meta-data/security-groups
	print_normal_metric user-data user-data
}
