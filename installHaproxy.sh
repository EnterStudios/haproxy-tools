#!/bin/bash -x
#
# This script installs haproxy


yum -q -y update

echo "installing haproxy ..."

function killYumUpdatesd {
	updatesdPid=`ps -ef | grep /usr/sbin/yum-updatesd | grep -v grep | awk '{print $2}'`
	echo ${updatesdPid}
	if [ ! -z ${updatesdPid} ]; then 
		kill -9 ${updatesdPid}
	fi
}

echo "Kill yum-updatesd if it is running."
killYumUpdatesd

echo "http_proxy is ${http_proxy}"

if rpm -qa | grep -q epel-release; then
	echo "epel is already installed"
else
	wget -O /tmp/epel-release-6-8.noarch.rpm http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
	rpm -Uvh /tmp/epel-release-6-8.noarch.rpm
fi

if rpm -qa | grep -q haproxy; then
	echo "haproxy is already installed"
fi

wget ftp://rpmfind.net/linux/centos/6.6/os/x86_64//Packages/haproxy-1.5.2-2.el6.x86_64.rpm
yum -q -y localinstall haproxy-1.5.2-2.el6.x86_64.rpm

echo "haproxy installed"

echo "customizing haproxy.cfg..."

# binding the frontend to the 8080 port
sed -i 's/frontend  main \*:5000/frontend  main \*:8080/' /etc/haproxy/haproxy.cfg
# using the app backend for the static content as well
sed -i 's/use_backend static/use_backend app/' /etc/haproxy/haproxy.cfg

echo "customizing haproxy.cfg: done!"

echo "starting haproxy..."

service haproxy start

echo "cleaning up..."

rm -rf haproxy-1.5.2-2.el6.x86_64.rpm

echo "downloading haproxy scripts..."

# for adding a node
#wget https://[url]/addNode.sh
#chmod +x addNode.sh
# for removing a node
#wget https://[url]/removeNode.sh
#chmod +x removeNode.sh

echo "done!"