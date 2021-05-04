#!/bin/sh

if ifconfig eth1 &>/dev/null; then
    [ -n "${MAC_IPTV_U7D}" ] && ifconfig eth0 hw ether ${MAC_IPTV_U7D}
    [ -n "${MAC_MOVISTAR_U7D}" ] && ifconfig eth1 hw ether ${MAC_MOVISTAR_U7D}
    ip route del 0.0.0.0/0 via ${IPTV_GW} dev eth0
    ip route add 172.0.0.0/11 via ${IPTV_GW} dev eth0
    ip route add 0.0.0.0/0 via ${U7D_GW} dev eth1
fi

echo "nameserver 172.26.23.3" > /etc/resolv.conf
echo "nameserver 127.0.0.1" >> /etc/resolv.conf
echo "172.26.22.23 www-60.svc.imagenio.telefonica.net" >> /etc/hosts
echo "172.26.83.49 html5-static.svc.imagenio.telefonica.net" >> /etc/hosts

while ! test -e "${HOME:-/home}/MovistarTV.m3u"; do
    /app/tv_grab_es_movistartv --m3u "${HOME:-/home}/MovistarTV.m3u"
    sleep 15
done

( while (true); do /app/movistar-epg.py; sleep 1; done ) &
( while (true); do /app/movistar-u7d.py; sleep 1; done ) &

tail -f /dev/null
