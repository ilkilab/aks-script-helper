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
  --protected-settings "{\"username\":\"azureuser\", \"ssh_key\":\"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCs/Mde8ivvzJo0AeqKywxhY3ObA2OK62ahvoDd7vm6EgQ61XbvlYv4Mlvac1OvYz/MsM9wRs3kHY88xRkdYFgKQelT4weXekkxpuecKKFYy/6L2Rojm1OFX+C9pibiDsht4E0mfhmkC3TLfmQHVkNbiBMhv7tWakGKxaPWhqbZXD0a+Dz4zMTphHG5ayUocIZvlYTkwmXacA9ZG8Gz7u7xjcE7e8bbe2rdbhlnhX/nOed8zsxNQCO7ixH90IfX/sxa5vCbYSFGrZqJPGX/I2+xFqdgdby6WhhV8rxmVlMvGvG5M1SRWxsHU94KZ8tEFuJdAPPfm6pXk5YMvLX39fF0lHjXa7cQAefb/utEqci5nPlUaGrTlDF6xyuuDR2p3L90PfR4CwIRQ6WdX9V0prx+cPdQPDQans0EQW03JkOwlOgeQBHRSZG+xWU9y+WcpxDd7Eu5yR5cgDJ1OP7u23lI5TtShuNx7eZEVJIPY9C79WtqfBgsdLsvdKa7KuDxNP8=\"}"

az vmss update-instances --instance-ids '*' \
    --resource-group $CLUSTER_RESOURCE_GROUP \
    --name $SCALE_SET_NAME
