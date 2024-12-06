#!/bin/bash

# Update package list and install essential packages
# Updates the package list and installs wget, openjdk-8-jdk, and ssh for system setup
sudo apt-get update
sudo apt-get install -y wget openjdk-8-jdk ssh

# Generate SSH keys and configure SSH for localhost
# Generates an SSH key pair and sets up passwordless SSH access to localhost
ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 0600 ~/.ssh/authorized_keys
ssh -o "StrictHostKeyChecking=no" localhost 'echo "SSH connection successful!"'

# Download and install Hadoop 1.2.1
# Downloads Hadoop 1.2.1 from the official Apache archives and installs it
wget https://archive.apache.org/dist/hadoop/common/hadoop-1.2.1/hadoop-1.2.1.tar.gz
tar -xzf hadoop-1.2.1.tar.gz
sudo mv hadoop-1.2.1 /usr/local/hadoop/
sudo chown -R ubuntu:ubuntu /usr/local/hadoop

# Configure environment variables
# Adds environment variables for Hadoop and Java to the .bashrc file
cat >> ~/.bashrc <<EOL
export HADOOP_PREFIX=/usr/local/hadoop/
export PATH=$PATH:$HADOOP_PREFIX/bin
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export PATH=$PATH:$JAVA_HOME
EOL

# Reload bash profile to apply changes
# Reloads the .bashrc file to ensure the new environment variables are available
source ~/.bashrc

# Configure Hadoop environment
# Adds Java home and network stack preference to Hadoop's environment settings
cat >> /usr/local/hadoop/conf/hadoop-env.sh <<EOL
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export HADOOP_OPTS=-Djava.net.preferIPv4Stack=true
EOL

# Configure Hadoop core-site.xml
# Configures Hadoop's core-site.xml to define the default filesystem and temporary directory
sudo sed -i '/<configuration>/,/<\/configuration>/d' /usr/local/hadoop/conf/core-site.xml
cat >> /usr/local/hadoop/conf/core-site.xml <<EOL
<configuration>
    <property>
        <name>fs.default.name</name>
        <value>hdfs://localhost:9000</value>
    </property>
    <property>
        <name>hadoop.tmp.dir</name>
        <value>/usr/local/hadoop/hdfs/tmp</value>
    </property>
</configuration>
EOL

# Configure Hadoop hdfs-site.xml
# Sets the replication factor and other HDFS-related configurations in hdfs-site.xml
sudo sed -i '/<configuration>/,/<\/configuration>/d' /usr/local/hadoop/conf/hdfs-site.xml
cat >> /usr/local/hadoop/conf/hdfs-site.xml <<EOL
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>1</value>
    </property>
</configuration>
EOL

# Configure Hadoop mapred-site.xml
# Configures the mapreduce job tracker in mapred-site.xml
sudo sed -i '/<configuration>/,/<\/configuration>/d' /usr/local/hadoop/conf/mapred-site.xml
cat >> /usr/local/hadoop/conf/mapred-site.xml <<EOL
<configuration>
    <property>
        <name>mapred.job.tracker</name>
        <value>localhost:9001</value>
    </property>
</configuration>
EOL

# Format Hadoop namenode
# Formats the Hadoop namenode to initialize the HDFS
/usr/local/hadoop/bin/hadoop namenode -format

# Start Hadoop services
# Starts all Hadoop services, including the Namenode and Datanode
/usr/local/hadoop/bin/start-all.sh

# Author: Rushikesh Shinde
# Contact: +91 9623548002
