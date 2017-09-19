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
cp -f certs/openshift.key ansible/openshift.key
cp -f templates/host-preparation-inventory ansible/inventory/hosts
NODE_MAX_INDEX=$((NODE_COUNT-1))
sed -i "s/###NODE_COUNT###/$NODE_MAX_INDEX/g" ansible/inventory/hosts
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
cp -f ../terraform-azure-openshift/certs/openshift.key openshift.key
cp -f ../terraform-azure-openshift/templates/openshift-inventory openshift-inventory
NODE_MAX_INDEX=$((NODE_COUNT-1))
sed -i "s/###NODE_COUNT###/$NODE_MAX_INDEX/g" openshift-inventory
sed -i "s/###ADMIN_USER###/$ADMIN_USER/g" openshift-inventory
ansible-playbook --private-key=openshift.key -i openshift-inventory playbooks/byo/config.yml
cd ..

rm install.sh
