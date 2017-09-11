#!/bin/bash
set -e

cd terraform

echo "Synchronizing Terraform state..."
terraform refresh -var-file=../azure.tfvars -var-file=../bootstrap.tfvars

echo "Planning Terraform changes..."
terraform plan -out openshift.plan -var-file=../azure.tfvars -var-file=../bootstrap.tfvars

echo "Deploying Terraform plan..."
terraform apply openshift.plan

echo "Getting the public IP for bastion server..."
BASTION_IP=$(terraform output bastion_public_ip)
echo "--> $BASTION_IP"

echo "Getting the selected node count..."
NODE_COUNT=$(terraform output node_count)
echo "--> $NODE_COUNT"

echo "Getting the admin user name..."
ADMIN_USER=$(terraform output admin_user)
echo "--> $ADMIN_USER"

cd ..

echo "Attempting to connect to bastion server..."
index=1
maxConnectionAttempts=10
sleepSeconds=5
while (( $index <= $maxConnectionAttempts ))
do
  ssh -o StrictHostKeychecking=no -i certs/bastion.key $ADMIN_USER@$BASTION_IP pwd >/dev/null
  case $? in
    (0) echo "Success!!"; break ;;
    (*) echo "${index} of ${maxConnectionAttempts}> Bastion SSH server not ready yet, waiting ${sleepSeconds} seconds..." ;;
  esac
  sleep $sleepSeconds
  (( index+=1 ))
done

echo "Transfering private key to bastion server..."
scp -o StrictHostKeychecking=no -i certs/bastion.key certs/openshift.key $ADMIN_USER@$BASTION_IP:/home/openshift/.ssh/id_rsa

echo "Transfering install script to bastion server..."
scp -o StrictHostKeychecking=no -i certs/bastion.key scripts/install.sh $ADMIN_USER@$BASTION_IP:/home/openshift/install.sh

echo "Running install script on bastion server..."
ssh -t -o StrictHostKeychecking=no -i certs/bastion.key $ADMIN_USER@$BASTION_IP ./install.sh $NODE_COUNT $ADMIN_USER
