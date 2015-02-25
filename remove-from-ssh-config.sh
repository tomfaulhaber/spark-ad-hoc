#!/bin/bash

# Remove the entry for spark-master and the supplied IP number from the ssh-config file

MASTER_IP=$1

if [ -z "${MASTER_IP}" ]
then
    echo "Usage: remove-from-ssh-config.sh <master-ip>"
    exit 1
fi

sed -ie "/Host ${MASTER_IP}\$/,/^\$/d" ~/.ssh/config
sed -ie "/Host spark-master\$/,/^\$/d" ~/.ssh/config
