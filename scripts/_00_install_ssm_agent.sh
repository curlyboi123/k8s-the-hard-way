#!/bin/bash
echo "Installing SSM agent"

mkdir /tmp/ssm

cd /tmp/ssm

wget -q https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_arm64/amazon-ssm-agent.deb

sudo dpkg -i amazon-ssm-agent.deb

sudo systemctl status --no-pager amazon-ssm-agent
