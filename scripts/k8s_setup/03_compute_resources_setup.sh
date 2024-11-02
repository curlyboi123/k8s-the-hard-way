#!/bin/bash
su - root
cd /root/kubernetes-the-hard-way

# Generate and Distribute SSH Keys
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

# Hostnames
while read IP FQDN HOST SUBNET; do 
    CMD="sed -i 's/^127.0.1.1.*/127.0.1.1\t${FQDN} ${HOST}/' /etc/hosts"
    ssh -n root@${IP} "$CMD"
    ssh -n root@${IP} hostnamectl hostname ${HOST}
done < machines.txt

while read IP FQDN HOST SUBNET; do
  ssh -n root@${IP} hostname --fqdn
done < machines.txt

# DNS
echo "" > hosts
echo "# Kubernetes The Hard Way" >> hosts

while read IP FQDN HOST SUBNET; do 
    ENTRY="${IP} ${FQDN} ${HOST}"
    echo $ENTRY >> hosts
done < machines.txt

cat hosts

# Adding DNS Entries To A Local Machine
cat hosts >> /etc/hosts

cat /etc/hosts

for host in server node-0 node-1
   do ssh root@${host} uname -o -m -n
done

# Adding DNS Entries To The Remote Machines
while read IP FQDN HOST SUBNET; do
  scp hosts root@${HOST}:~/
  ssh -n \
    root@${HOST} "cat hosts >> /etc/hosts"
done < machines.txt
