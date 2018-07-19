#!/bin/bash
set -e

NODE_COUNT=$1
MASTER_COUNT=$2
INFRA_COUNT=$3
ADMIN_USER=$4
MASTER_DOMAIN=$5
ROUTER_DOMAIN=$6
MASTER_FQDN=$7

cd terraform-azure-openshift

chmod 600 certs/*
cp -f certs/openshift.key ansible/openshift.key
cp -f templates/host-preparation-inventory ansible/inventory/hosts
sed -i "s/###NODE_COUNT###/$NODE_COUNT/g" ansible/inventory/hosts
sed -i "s/###MASTER_COUNT###/$MASTER_COUNT/g" ansible/inventory/hosts
sed -i "s/###INFRA_COUNT###/$INFRA_COUNT/g" ansible/inventory/hosts
sed -i "s/###ADMIN_USER###/$ADMIN_USER/g" ansible/inventory/hosts

cd ansible
ansible-playbook -i inventory/hosts host-preparation.yml
cd ../..

if [ ! -d "openshift-ansible" ]; then
    echo "Cloning openshift-ansible Github repo..."
    git clone https://github.com/openshift/openshift-ansible
fi

cd openshift-ansible
git checkout release-3.9
git pull
cp -f ../terraform-azure-openshift/certs/openshift.key openshift.key
cp -f ../terraform-azure-openshift/templates/openshift-inventory openshift-inventory

sed -i "s/###NODE_COUNT###/$NODE_COUNT/g" openshift-inventory
sed -i "s/###MASTER_COUNT###/$MASTER_COUNT/g" openshift-inventory
sed -i "s/###INFRA_COUNT###/$INFRA_COUNT/g" openshift-inventory
sed -i "s/###ADMIN_USER###/$ADMIN_USER/g" openshift-inventory
sed -i "s/###MASTER_DOMAIN###/$MASTER_DOMAIN/g" openshift-inventory
sed -i "s/###ROUTER_DOMAIN###/$ROUTER_DOMAIN/g" openshift-inventory
sed -i "s/###MASTER_FQDN###/$MASTER_FQDN/g" openshift-inventory

ansible-playbook --private-key=openshift.key -i openshift-inventory playbooks/prerequisites.yml
ansible-playbook --private-key=openshift.key -i openshift-inventory playbooks/deploy_cluster.yml

cd ..

rm -rf .kube
scp -q -r master1.openshift.local:.kube .kube

rm install.sh
