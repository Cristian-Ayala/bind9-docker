echo 1 > /proc/sys/net/ipv6/conf/all/forwarding

echo 1 > /proc/sys/net/ipv6/conf/default/forwarding
        /proc/sys/net/ipv6/conf/all/forwarding 


--------------------------------------------------------------------------------------------------


export slave_ipv6='2001:0:53aa:64c:201a:2eb1:dc17:41ea' 

export master_ipv6=$(ip -6 addr show dev teredo scope global | sed -e's/^.*inet6 \([^ ]*\)\/.*$/\1/;t;d')



----------------------------------------------------------------------------------------------------



docker run -dti --name bind -e master_ipv6=$master_ipv6 -e slave_ipv6=$slave_ipv6 -e master_ip="10.10.10.10" -e slave_ip="20.20.20.20" --network=host -i bind9

