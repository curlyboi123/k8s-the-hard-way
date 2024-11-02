#!/bin/bash
sed -i \
  's/^#PermitRootLogin.*/PermitRootLogin yes/' \
  /etc/ssh/sshd_config

sed -i \
    's/^PasswordAuthentication no.*/PasswordAuthentication yes/' \
    /etc/ssh/sshd_config

sed -i \
    's/^#PermitEmptyPasswords.*/PermitEmptyPasswords yes/' \
    /etc/ssh/sshd_config

passwd root -d

systemctl restart sshd
