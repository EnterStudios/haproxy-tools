#!/bin/bash -x
#
# Removing a server to the ha proxy
#	
# Usage:
#
# removeNode.sh "node"
#
# ./removeNode.sh "test-srv" | "8.8.8.8"
#


haconfig="/etc/haproxy/haproxy.cfg"
hapid="/var/run/haproxy.pid"

if test -z "$1"; then
    echo "error: please specify a node"
    exit 1
else
    node="$1"
fi


if [ -f ${haconfig} ] ; 
	then echo "using the following config file ${haconfig}" ; 
else echo "missing the haproxy config file" 
	exit 1; 
fi

#sed -i -e :a -e '/^\n*$/{$d;N;};/\n$/ba' $haconfig

sed -i "/${node}/d" $haconfig

echo "" >> $haconfig

# reloading haproxy
echo "reloading haproxy configuration..."

if [ -f ${hapid} ] ; 
	then echo "using the following pid file ${hapid}" ; 
else echo "missing the haproxy pid file" 
	exit 1; 
fi

haproxy -f ${haconfig} -p ${hapid} -sf $(<${hapid})

echo "haproxy configuration reloaded!"