#!/bin/bash
#command    policy                          table       chain           protocol    src_ip                  dest_ip                 src_port        dest_port       match module                        in-interface    out-interface   action
#iptables   -P INPUT ACCEPT|REJECT|DROP     -t filter   -A INPUT        -p all      -s ###.###.###.###/##   -d ###.###.###.###/##   --sport ######  --dport ######  -m state --limit <number>/<time>    -i lo           -o lo           -j ACCEPT    
#              OUTPUT ACCEPT|REJECT|DROP       nat      -I OUTPUT          tcp                                                                                               --limit-burst                 eth*            eth*            DROP
#              FORWARD ACCEPT|REJECT|DROP      mangle      FORWARD         udp                                                                                               --mac-source                  wlan*           wlan*           REJECT
#                                              raw         PREROUTING      icmp --icmp-type any                                                                              --state NEW                   ...             ...             LOG
#                                                          POSTROUTING                      echo-request                                                                             RELATED                                               MASQUERADE
#                                                                                           echo-reply                                                                               INVALID
#                                                                                           destination-unreachable                                                                  ESTABLISHED
#                                                                                           time-exceed                                                                conntack -- ctstate NEW
#                                                                                                                                                                                          RELATED
#                                                                                                                                                                                          INVALID
#                                                                                                                                                                                          ESTABLISHED

# To-Do: Rename "REJECT" to "DROP" after testing.

# Set default chain policies
#iptables   -P INPUT REJECT
#iptables   -P FORWARD REJECT
#iptables   -P OUTPUT ACCEPT

# Accept loopback access
#iptables                                               -A INPUT        -p all                                                                                                                          -i lo                           -j ACCEPT
#iptables                                               -A OUTPUT       -p all                                                                                                                                          -o lo           -j ACCEPT

# Accept internal network to external network
#iptables                                               -A FORWARD                                                                                                                                      -i eth0         -o eth1         -j ACCEPT

# Accept outgoing traffic
#iptables                                               -A OUTPUT                                           -d 0.0.0.0/0                                                                                                                -j ACCEPT

# Accept ping from outside to inside
#iptables                                               -A INPUT        -p icmp --icmp-type echo-request                                                                                                                                -j ACCEPT
#iptables                                               -A OUTPUT       -p icmp --icmp-type echo-reply                                                                                                                                  -j ACCEPT

# Accept ping from inside to outside
#iptables                                               -A OUTPUT       -p icmp --icmp-type echo-request                                                                                                                                -j ACCEPT
#iptables                                               -A INPUT        -p icmp --icmp-type echo-reply                                                                                                                                  -j ACCEPT

# Accept ping from outside to inside

# Accept rsync (Port: 873)
#iptables                                               -A INPUT        -p tcp                                                              --dport 873     -m state --state NEW, ESTABLISHED                                           -j ACCEPT
#iptables                                               -A OUTPUT       -p tcp                                              --sport 873                     -m state --state ESTABLISHED                                                -j ACCEPT

# Accept incoming SSH (Port: 22)
#iptables                                               -A INPUT        -p tcp                                                              --dport 22      -m state --state NEW, ESTABLISHED                                           -j ACCEPT
#iptables                                               -A OUTPUT       -p tcp                                              --sport 22                      -m state --state ESTABLISHED                                                -j ACCEPT

# Accept outgoing SSH (Port: 22)
#iptables                                               -A OUTPUT       -p tcp                                                              --dport 22      -m state --state NEW, ESTABLISHED                                           -j ACCEPT
#iptables                                               -A INPUT        -p tcp                                              --sport 22                      -m state --state ESTABLISHED                                                -j ACCEPT

# Accept incoming HTTP (Port: 80)
#iptables                                               -A INPUT        -p tcp                                                              --dport 80      -m state --state NEW, ESTABLISHED                                           -j ACCEPT
#iptables                                               -A OUTPUT       -p tcp                                                              --dport 80      -m state --state ESTABLISHED                                                -j ACCEPT

# Accept incoming HTTPS (Port: 443)
#iptables                                               -A INPUT        -p tcp                                                              --dport 443     -m state --state NEW, ESTABLISHED                                           -j ACCEPT
#iptables                                               -A OUTPUT       -p tcp                                              --sport 443                     -m state --state ESTABLISHED                                                -j ACCEPT

# Accept outgoing HTTPS (Port: 443)
#iptables                                               -A OUTPUT       -p tcp                                                              --dport 443     -m state --state NEW, ESTABLISHED                                           -j ACCEPT
#iptables                                               -A INPUT        -p tcp                                              --sport 443                     -m state --state ESTABLISHED                                                -j ACCEPT

# Accept openVPN (Port: 1194) (Routing: tun0 = 10.8.0.1 / eth0 = 192.168.0.1) https://community.openvpn.net/openvpn/wiki/BridgingAndRouting
# Accept traffic from VPN to LAN
#iptables                                               -I FORWARD                  -s 10.8.0.0/24          -d 192.168.0.0/24                               -m conntrack --ctstate NEW                  -i tun0         -o eth0         -j ACCEPT
# Accept traffic from VPN to WAN
#iptables                                               -I FORWARD                  -s 10.8.0.0/24                                                          -m conntrack --ctstate NEW                  -i tun0         -o eth1         -j ACCEPT               
# Accept traffic from LAN to WAN
#iptables                                               -I FORWARD                  -s 192.168.0.0/24                                                       -m conntrack --ctstate NEW                  -i eth0         -o eth1         -j ACCEPT
# Accept established traffic to pass back and forth
#iptables                                               -I FORWARD                                                                                          -m conntrack --ctstate RELATED, ESTABLISHED                                 -j ACCEPT
# Masquerade traffic from VPN to WAN
#iptables                                   -t nat      -I POSTROUTING              -s 10.8.0.0/24                                                                                                                      -o eth1         -j MASQUERADE
# Masquerade traffic from LAN to WAN
#iptables                                   -t nat      -I POSTROUTING              -s 192.168.0.0/24                                                                                                                   -o eth1         -j MASQUERADE

# NAT (Raspberry Pi)
#iptables                                   -t nat      -A POSTROUTING                                                                                                                                                  -o wlan0        -j MASQUERADE

# DROP everything else which is not accepted
#iptables                                               -A INPUT                                                                                                                                                                        -j REJECT
