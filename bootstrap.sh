#!/bin/bash
set -e

cd terraform

echo "Synchronizing Terraform state..."
terraform refresh -var-file=../bootstrap.tfvars

echo "Planning Terraform changes..."
terraform plan -out openshift.plan -var-file=../bootstrap.tfvars

echo "Deploying Terraform plan..."
terraform apply openshift.plan

echo "Getting output variables..."
BASTION_IP=$(terraform output bastion_public_ip)
SERVICE_IP=$(terraform output service_public_ip)
CONSOLE_IP=$(terraform output console_public_ip)
NODE_COUNT=$(terraform output node_count)
ADMIN_USER=$(terraform output admin_user)
MASTER_DOMAIN=$(terraform output master_domain)

cd ..

chmod 600 certs/*

echo "Transfering private key to bastion server..."
scp -o StrictHostKeychecking=no -i certs/bastion.key certs/openshift.key $ADMIN_USER@$BASTION_IP:/home/$ADMIN_USER/.ssh/id_rsa

echo "Transfering install script to bastion server..."
scp -o StrictHostKeychecking=no -i certs/bastion.key scripts/install.sh $ADMIN_USER@$BASTION_IP:/home/$ADMIN_USER/install.sh

echo "Running install script on bastion server..."
ssh -t -o StrictHostKeychecking=no -i certs/bastion.key $ADMIN_USER@$BASTION_IP ./install.sh $NODE_COUNT $ADMIN_USER $MASTER_DOMAIN

echo "Finished!!"
echo "Console: https://$CONSOLE_IP:8443"
echo "Bastion: ssh -i certs/bastion.key $ADMIN_USER@$BASTION_IP"
echo "Router: $SERVICE_IP"
