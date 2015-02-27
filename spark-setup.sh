#!/bin/bash

set -x

# IPYTHON=yes

MASTER_IP=$1
SPARK_MASTER=mesos://zk://${MASTER_IP}:2181/mesos

SPARK_SRC=http://apache.arvixe.com/spark/spark-1.2.0
SPARK_DIR=spark-1.2.0-bin-hadoop2.4
SPARK_FILE=${SPARK_DIR}.tgz

# Install packages
apt-get -y install tmux
apt-get -y install mosh

# Get Spark and put it in HDFS
wget -q ${SPARK_SRC}/${SPARK_FILE}
tar xf ${SPARK_FILE}
hdfs dfs -mkdir /tmp
hdfs dfs -put ${SPARK_FILE} /tmp
rm ${SPARK_FILE}

# Configure Spark
cd ${SPARK_DIR}
cd conf
cp spark-env.sh.template spark-env.sh
cat >> spark-env.sh <<EOF
export MESOS_NATIVE_LIBRARY=/usr/local/lib/libmesos.so
export SPARK_EXECUTOR_URI=hdfs://${MASTER_IP}/tmp/${SPARK_FILE}
export MASTER=${SPARK_MASTER}
export SPARK_LOCAL_IP=${MASTER_IP}
export SPARK_PUBLIC_DNS=${MASTER_IP}
EOF

cp spark-defaults.conf.template spark-defaults.conf
cat >> spark-defaults.conf <<EOF
spark.executor.uri           hdfs://${MASTER_IP}/tmp/spark-1.2.0-bin-hadoop2.4.tgz
EOF

sed 's/log4j.rootCategory=INFO/log4j.rootCategory=WARN/' < log4j.properties.template > log4j.properties

cd ..

# Update environment
cat >> ~/.profile <<EOF
export PATH=${SPARK_DIR}/bin:${PATH}
export SPARK_MASTER=${SPARK_MASTER}
EOF

# Run an IPython notebook server
if [ ! -z "${IPYTHON+x}" ]
then
    apt-get -y install python-dev
    pip install pyzmq
    pip install "ipython[notebook]"

    mkdir ~/notebook
    IPYTHON_OPTS="notebook --ip=0.0.0.0 --no-browser --notebook-dir=${HOME}/notebook --no-stdout --no-stderr " bin/pyspark --master ${SPARK_MASTER} &
fi
