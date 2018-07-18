#!/bin/bash
set -e

NODE_COUNT=$1
ADMIN_USER=$2
MASTER_DOMAIN=$3

if [ ! -d "terraform-azure-openshift" ]; then
    echo "Cloning terraform-azure-openshift Github repo..."
    git clone https://github.com/drhelius/terraform-azure-openshift
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
    git clone https://github.com/openshift/openshift-ansible
fi

cd openshift-ansible
git checkout release-3.9
git pull
cp -f ../terraform-azure-openshift/certs/openshift.key openshift.key
cp -f ../terraform-azure-openshift/templates/openshift-inventory openshift-inventory

INDEX=0
while [ $INDEX -lt $NODE_COUNT ]; do
  printf "node$INDEX openshift_hostname=ocp-app-$INDEX openshift_node_labels=\"{'role':'app', 'logging':'true'}\"\n" >> openshift-inventory
  let INDEX=INDEX+1
done

sed -i "s/###ADMIN_USER###/$ADMIN_USER/g" openshift-inventory
sed -i "s/###MASTER_DOMAIN###/$MASTER_DOMAIN/g" openshift-inventory
ansible-playbook --private-key=openshift.key -i openshift-inventory playbooks/prerequisites.yml
ansible-playbook --private-key=openshift.key -i openshift-inventory playbooks/deploy_cluster.yml

cd ..

rm install.sh
