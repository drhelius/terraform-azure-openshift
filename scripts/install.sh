#!/bin/bash
set -e

NODE_COUNT=$1
ADMIN_USER=$2

if [ ! -d "terraform-azure-openshift" ]; then
    echo "Cloning terraform-azure-openshift Github repo..."
    git clone https://github.com/drhelius/terraform-azure-openshift.git
fi

cd terraform-azure-openshift
git pull

chmod 600 certs/*
cp -f templates/host-preparation-inventory ansible/inventory/hosts
sed -i "s/###NODE_COUNT###/$NODE_COUNT/g" ansible/inventory/hosts
sed -i "s/###ADMIN_USER###/$ADMIN_USER/g" ansible/inventory/hosts

cd ansible
ansible-playbook -i inventory/hosts host-preparation.yml
cd ../..

if [ ! -d "openshift-ansible" ]; then
    echo "Cloning openshift-ansible Github repo..."
    git clone https://github.com/openshift/openshift-ansible.git
fi

cd openshift-ansible
git pull
cd ..

rm install.sh
