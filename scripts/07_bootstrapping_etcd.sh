#!/bin/bash
su - root
cd /root/kubernetes-the-hard-way

# Prerequisites
scp \
  downloads/etcd-v3.4.27-linux-arm64.tar.gz \
  units/etcd.service \
  root@server:~/

# Run commands on server instance
ssh root@server

# Bootstrapping an etcd Cluster
{
  tar -xvf etcd-v3.4.27-linux-arm64.tar.gz
  mv etcd-v3.4.27-linux-arm64/etcd* /usr/local/bin/
}

# Configure the etcd Server
{
  mkdir -p /etc/etcd /var/lib/etcd
  chmod 700 /var/lib/etcd
  cp ca.crt kube-api-server.key kube-api-server.crt \
    /etc/etcd/
}

mv etcd.service /etc/systemd/system/

# Start the etcd Server
{
  systemctl daemon-reload
  systemctl enable etcd
  systemctl start etcd
}

# Verification
etcdctl member list

# Return to jumpbox
exit