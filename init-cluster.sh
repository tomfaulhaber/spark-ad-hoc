#!/bin/sh

identity=~/.ssh/digital-ocean
dir=$(dirname $0)
MASTER_IP=$1

if [ -z "${MASTER_IP}" ]
then
    echo "Usage: init-cluster.sh <master-ip>"
    exit 1
fi

# set up the ssh/config, so that we can use the master without a lot of ceremony
${dir}/add-to-ssh-config.sh ${MASTER_IP} ${identity}

# The list of executors is the same as the list of HDFS nodes, so use that as a proxy
executors=$(ssh ${MASTER_IP} hdfs dfsadmin -printTopology | sed -e '/^[^ ]/d' | sed -e '/^$/d' | sed -e 's/ *\([^:]*\):.*$/\1/')
allhosts="${MASTER_IP} ${executors}"

# MLLib needs native BLAS so make sure all the nodes have it
for host in ${allhosts}
do
    ssh -i ${identity} -o "StrictHostKeyChecking no" -o "UserKnownHostsFile /dev/null" root@${host} apt-get install libgfortran3
done

scp spark-setup.sh ${MASTER_IP}:
scp tmux.conf ${MASTER_IP}:.tmux.conf

ssh ${MASTER_IP} bash ./spark-setup.sh ${MASTER_IP}
