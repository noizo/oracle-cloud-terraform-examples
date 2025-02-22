#!/bin/bash

# Disable firewall 
/usr/sbin/netfilter-persistent stop
/usr/sbin/netfilter-persistent flush

systemctl stop netfilter-persistent.service
systemctl disable netfilter-persistent.service

# END Disable firewall

apt-get update
apt-get install -y software-properties-common jq
DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

local_ip=$(curl -s -H "Authorization: Bearer Oracle" -L http://169.254.169.254/opc/v2/vnics/ | jq -r '.[0].privateIp')
flannel_iface=$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)')

until (curl -sfL https://get.k3s.io | K3S_TOKEN=${k3s_token} K3S_URL=https://${k3s_url}:6443 sh -s - --node-ip $local_ip --flannel-iface $flannel_iface); do
    echo 'k3s did not install correctly'
    sleep 2
done