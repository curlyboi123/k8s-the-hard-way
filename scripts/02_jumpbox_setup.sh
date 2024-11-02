#!/bin/bash
su - root

cd /root

apt update
apt-get -y install wget curl vim openssl git

git clone --depth 1 https://github.com/kelseyhightower/kubernetes-the-hard-way.git

cd kubernetes-the-hard-way

mv /tmp/machines.txt ./

mkdir downloads

wget -q \
  --https-only \
  -P downloads \
  -i downloads.txt

{
  chmod +x downloads/kubectl
  cp downloads/kubectl /usr/local/bin/
}
