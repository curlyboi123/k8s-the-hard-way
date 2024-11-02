#!/bin/bash
su - root

cd /root

apt update
apt-get -y install wget curl vim openssl git

git clone --depth 1 https://github.com/kelseyhightower/kubernetes-the-hard-way.git

cd kubernetes-the-hard-way

mv /root/machines.txt ./

mkdir downloads

wget -q \
  --https-only \
  -P downloads \
  -i downloads.txt

{
  chmod +x downloads/kubectl
  cp downloads/kubectl /usr/local/bin/
}

cat <<EOT >> /root/.ssh/config
Host *
  StrictHostKeyChecking no
EOT

ssh-keygen -b 2048 -t rsa -f /root/.ssh/id_rsa -q -N ""

while read IP FQDN HOST SUBNET; do
  ssh-copy-id root@${IP}
done < machines.txt

while read IP FQDN HOST SUBNET; do
  ssh -n root@${IP} uname -o -m
done < machines.txt
