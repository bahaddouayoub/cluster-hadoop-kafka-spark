FROM ubuntu

MAINTAINER ayou.samir@gmail.com 

WORKDIR /root

# install openssh-server, openjdk and wget
RUN apt-get update && apt-get install -y openssh-server openjdk-11-jdk wget

# install hadoop 2.7.2
RUN wget https://dlcdn.apache.org/hadoop/common/hadoop-3.3.4/hadoop-3.3.4.tar.gz && \
    tar -xzvf hadoop-3.3.4.tar.gz && \ 
    mkdir -p /usr/local/hadoop && \
    mv hadoop-3.3.4 /usr/local/hadoop && \
    rm hadoop-3.3.4.tar.gz
    
# install kafka and zookeper


# set environment variable
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64 
ENV HADOOP_HOME=/usr/local/hadoop/hadoop-3.3.4 
ENV PATH=$PATH:/usr/local/hadoop/bin:/usr/local/hadoop/sbin 

# ssh without key
RUN ssh-keygen -t rsa -f ~/.ssh/id_rsa -P '' && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

RUN mkdir -p ~/hdfs/namenode && \ 
    mkdir -p ~/hdfs/datanode && \
    mkdir $HADOOP_HOME/logs

COPY config/* /tmp/

RUN mv /tmp/ssh_config ~/.ssh/config && \
    mv /tmp/hadoop-env.sh $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    mv /tmp/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \ 
    mv /tmp/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml && \
    mv /tmp/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml && \
    mv /tmp/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
    mv /tmp/slaves $HADOOP_HOME/etc/hadoop/slaves && \
    mv /tmp/start-hadoop.sh ~/start-hadoop.sh && \
    mv /tmp/run-wordcount.sh ~/run-wordcount.sh 


RUN chmod +x ~/start-hadoop.sh && \
    chmod +x ~/run-wordcount.sh && \
    chmod +x $HADOOP_HOME/sbin/start-dfs.sh && \
    chmod +x $HADOOP_HOME/sbin/start-yarn.sh 

# format namenode
RUN $HADOOP_HOME/bin/hdfs namenode -format

CMD [ "sh", "-c", "service ssh start; bash"]

