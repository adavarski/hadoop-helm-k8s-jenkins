FROM java:8-jre

# Add native libs
ARG HADOOP_VERSION=2.9.0
ENV KEYS http://www-eu.apache.org/dist/hadoop/common/KEYS
ENV KEYS_TMP /tmp/KEYS
ENV HADOOP_INSTALLER hadoop-$HADOOP_VERSION.tar.gz
ENV HADOOP_NAME hadoop-$HADOOP_VERSION
ENV HADOOP_ASC $HADOOP_INSTALLER.asc
ENV HADOOP_ASC_URL http://www-eu.apache.org/dist/hadoop/common/$HADOOP_NAME/$HADOOP_ASC
ENV HADOOP_INSTALLER_URL http://ftp.man.poznan.pl/apache/hadoop/common/$HADOOP_NAME/$HADOOP_INSTALLER
ENV HADOOP_TMP_DIR /tmp/hadoop

RUN echo "--$HADOOP_INSTALLER_URL--"
RUN wget --no-check-certificate -c $KEYS -O $KEYS_TMP 2>&1 && \
    gpg --import $KEYS_TMP 2>&1 && \
    mkdir $HADOOP_TMP_DIR && \
    wget --no-check-certificate -c $HADOOP_INSTALLER_URL -O $HADOOP_TMP_DIR/$HADOOP_INSTALLER 2>&1 && \
    wget --no-check-certificate -c $HADOOP_ASC_URL -O $HADOOP_TMP_DIR/$HADOOP_ASC 2>&1 && \
    tar -xvzf $HADOOP_TMP_DIR/$HADOOP_INSTALLER -C /usr/local && \
    rm -rf /tmp/*


ENV HADOOP_PREFIX=/usr/local/hadoop \
    HADOOP_COMMON_HOME=/usr/local/hadoop \
    HADOOP_HDFS_HOME=/usr/local/hadoop \
    HADOOP_MAPRED_HOME=/usr/local/hadoop \
    HADOOP_YARN_HOME=/usr/local/hadoop \
    HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop \
    YARN_CONF_DIR=/usr/local/hadoop/etc/hadoop \
    PATH=${PATH}:/usr/local/hadoop/bin

RUN \
  cd /usr/local && ln -s ./hadoop-${HADOOP_VERSION} hadoop && \
  rm -f ${HADOOP_PREFIX}/logs/*

WORKDIR $HADOOP_PREFIX

# Hdfs ports
EXPOSE 50010 50020 50070 50075 50090 8020 9000
# Mapred ports
EXPOSE 19888
#Yarn ports
EXPOSE 8030 8031 8032 8033 8040 8042 8088
#Other ports
EXPOSE 49707 2122
