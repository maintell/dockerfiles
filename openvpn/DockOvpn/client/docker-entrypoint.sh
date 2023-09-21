#!/usr/bin/env bash


firstBool=""
if [ ! -f "/vpn/vpn.conf" ];then
  firstBool="1"
  wget -O /vpn/vpn.conf $DOCKOVPN_SERVER:8080
fi

# 需要tcp
# http-proxy 192.168.4.1 1080
if [ -n "firstBool" ];then
  if [ -n "$OPENVPN_HTTP_PROXY" ];then
    echo "http-proxy $OPENVPN_HTTP_PROXY" >> /vpn/vpn.conf
  fi
fi

exec /usr/bin/openvpn.sh
