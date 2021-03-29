echo 1 > /proc/sys/net/ipv6/conf/all/forwarding
echo 1 > /proc/sys/net/ipv6/conf/default/forwarding
export slave_ipv6='2001:0:53aa:64c:201a:2eb1:dc17:41ea' 
export master_ipv6=$(ip -6 addr show dev teredo scope global | sed -e's/^.*inet6 \([^ ]*\)\/.*$/\1/;t;d')
docker build --build-arg master_ipv6=$master_ipv6 --build-arg slave_ipv6=$slave_dns -t bind9 .
iptables -P FORWARD ACCEPT

docker run -dti --name bind --net my_ipv6_bridge --ip6 $master_ipv6 -i bind9  
docker run -dti --name static6 --net mynet --ip 172.80.80.58 
docker run -dti --name bind -p [$master_ipv6]:53:53 -p [$master_ipv6]:53:53/udp -e master_ipv6=$master_ipv6 -e slave_ipv6=$slave_ipv6 -e master_ip="10.10.10.10" -e slave_ip="20.20.20.20" --network=teredo -i bind9



docker run -dti --name bind -p 53:53 -p 53:53/udp -e master_ipv6=$master_ipv6 -e slave_ipv6=$slave_ipv6 -e master_ip="10.10.10.10" -e slave_ip="20.20.20.20" --network=teredo -i bind9

ip6tables -t nat -A POSTROUTING -s 2001:db8:1::/64 ! -o docker0 -j MASQUERADE
