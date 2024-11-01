#!/bin/bash

### Allow root ssh ###
# sed -i \
#   's/^#PermitRootLogin.*/PermitRootLogin yes/' \
#   /etc/ssh/sshd_config

# sed -i \
#     's/^PasswordAuthentication no.*/PasswordAuthentication yes/' \
#     /etc/ssh/sshd_config

# sed -i \
#     's/^#PermitEmptyPasswords.*/PermitEmptyPasswords yes/' \
#     /etc/ssh/sshd_config

# passwd root -d

# systemctl restart sshd
######
su - root

cd /root

ls

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

echo "make kubectl executable"
{
  chmod +x downloads/kubectl
  cp downloads/kubectl /usr/local/bin/
}
