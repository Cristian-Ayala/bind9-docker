FROM debian:bullseye

RUN apt-get -y update && apt-get install -y bind9 bind9utils bind9-doc dnsutils

WORKDIR /etc/bind/

ENV host='riguas' master_ip='10.0.1.34' master_ipv6='2001:0:53aa:64c:3836:ed54:41a9:9f7e'

ENV slave='tamales' slave_ip='172.168.0.1' slave_ipv6='2001:0:53aa:64c:201a:2eb1:dc17:41ea'

RUN echo '                                      \n\
zone "'$host'.com" {                            \n\
        type master;                            \n\
        file "/etc/bind/db.'$host'";            \n\
        notify yes;                             \n\
};                                              \n\
zone "'$slave'.com" {                           \n\
    type slave;                                 \n\
    masters { '$slave_ip'; };                  \n\
    file "db.'$slave'";                         \n\
};                                              \n\
' > named.conf.local

RUN cat named.conf.local

RUN echo '                                      \n\
options {                                       \n\
        directory "/var/cache/bind";            \n\
        allow-query { 2001::/32; };             \n\
        allow-transfer { any; };                \n\
        auth-nxdomain no;                       \n\  
        recursion no;                           \n\
        dnssec-validation auto;                 \n\
        listen-on-v6 { any; };                  \n\
};                                              \n\
' > named.conf.options

RUN cat named.conf.options

RUN echo '                                                              \n\
\$TTL    604800                                                         \n\
@       IN      SOA     '$host'.'$host'.com. root.'$host'.com. (        \n\
                             30         ; Serial                        \n\
                         604800         ; Refresh                       \n\
                          86400         ; Retry                         \n\
                        2419200         ; Expire                        \n\
                         604800 )       ; Negative Cache TTL            \n\
; Name Servers para el dominio                                          \n\
@       IN      NS      '$host'.'$host'.com.                            \n\
@       IN      NS      '$slave'.'$host'.com.                           \n\
; Los registros para direcciones Clase A                                \n\
'$host'         IN      A       '$master_ip'                            \n\
'$host'         IN      AAAA    '$master_ipv6'                          \n\
'$slave'        IN      A       '$slave_ip'                             \n\
'$slave'        IN      AAAA    '$slave_ipv6'                           \n\
www             IN      A       '$master_ip'                            \n\
www             IN      AAAA    '$master_ipv6'                          \n\
@               IN      A       '$master_ip'                            \n\
@               IN      AAAA    '$master_ipv6'                          \n\
' > db.${host}

RUN cat db.${host}

RUN /etc/init.d/named reload

EXPOSE 53 53/udp

