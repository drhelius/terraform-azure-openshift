#!/bin/bash
sudo yum -y install epel-release
sudo yum -y update
sudo yum -y install ansible pyOpenSSL wget git net-tools bind-utils yum-utils iptables-services bridge-utils bash-completion kexec-tools sos psacct tmux vim
