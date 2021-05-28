#!/bin/bash
cat <<EOF
###########################################################
#  Make sur you have an SSH Key Pair in ~/.ssh/id_rsa.pub #
#  IF not, run "ssh-keygen" command                       #
###########################################################
EOF

RESOURCE_GROUP=$1
AKS_CLUSTER=$2

if [ "${RESOURCE_GROUP}" = "" ];then
        read -p "AKS Resource Group: " RESOURCE_GROUP
fi
if [ "${AKS_CLUSTER}" = "" ];then
        read -sp "AKS Cluster Name: " AKS_CLUSTER
fi

CLUSTER_RESOURCE_GROUP=$(az aks show --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER --query nodeResourceGroup -o tsv)
SCALE_SET_NAME=$(az vmss list --resource-group $CLUSTER_RESOURCE_GROUP --query '[0].name' -o tsv)

az vmss extension set \
  --resource-group $CLUSTER_RESOURCE_GROUP \
  --vmss-name $SCALE_SET_NAME \
  --name VMAccessForLinux \
  --publisher Microsoft.OSTCExtensions \
  --version 1.4 \
  --protected-settings "{\"username\":\"azureuser\", \"ssh_key\":\"$(cat ~/.ssh/id_rsa.pub)\"}"

az vmss update-instances --instance-ids '*' \
    --resource-group $CLUSTER_RESOURCE_GROUP \
    --name $SCALE_SET_NAME
