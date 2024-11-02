#!/bin/bash
su - root
cd /root/kubernetes-the-hard-way

# Create missing encryption template file
cat <<EOT >> /root/kubernetes-the-hard-way/configs/encryption-config.yaml
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: ${ENCRYPTION_KEY}
      - identity: {}
EOT

export ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)

envsubst < configs/encryption-config.yaml \
  > encryption-config.yaml

  scp encryption-config.yaml root@server:~/