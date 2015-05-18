#!/bin/bash -x
#
# Adding a server to the ha proxy
#	
# Usage:
#
# addNode.sh "serverName" "server-ip" "server-port" "server-userdata"
#
# ./addNode.sh "test-srv" "8.8.8.8" "80" "check"


haconfig="/etc/haproxy/haproxy.cfg"
hapid="/var/run/haproxy.pid"

if test -z "$1"; then
    echo "error: please specify a name"
    exit 1
else
    name="$1"
fi

if test -z "$2"; then
    echo "error: please specify an ip address"
    exit 1
else
    ipaddr="$2"
fi

if test -z "$3"; then
    echo "error: please specify a port"
    exit 1
else
    port="$3"
fi


if [ -f ${haconfig} ] ; 
	then echo "using the following config file ${haconfig}" ; 
else echo "missing the haproxy config file" 
	exit 1; 
fi

sed -i -e :a -e '/^\n*$/{$d;N;};/\n$/ba' $haconfig #>> $haconfig

if test -z "$4"; then
    echo "info: proceeding w/o user data"
    echo "    server  ${name} ${ipaddr}:${port}" >> $haconfig
else
    userdata="$4"
    echo "info: proceeding with user data: ${userdata}"
    echo "    server  ${name} ${ipaddr}:${port} ${userdata}" >> $haconfig
fi

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