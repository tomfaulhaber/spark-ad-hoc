#!/bin/bash

dir=$(dirname $0)

MASTER_IP=$1
IDENTITY=$2

if [ -z "${MASTER_IP}" -o -z "${IDENTITY}" ]
then
    echo "Usage: add-to-ssh-config.sh <master-ip> <identity-file>"
    exit 1
fi

${dir}/remove-from-ssh-config.sh ${MASTER_IP}

cat <<EOF >> ~/.ssh/config
Host spark-master
  Hostname ${MASTER_IP}
  IdentityFile ${IDENTITY}
  User root
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null

Host  ${MASTER_IP}
  Hostname ${MASTER_IP}
  IdentityFile ${IDENTITY}
  User root
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
EOF
