#!/bin/bash
sudo yum -y install epel-release centos-release-openshift-origin
sudo yum -y update
sudo yum -y install ansible pyOpenSSL wget git net-tools bind-utils yum-utils iptables-services bridge-utils bash-completion kexec-tools sos psacct python-passlib httpd-tools java-1.8.0-openjdk-headless tmux vim origin-clients
