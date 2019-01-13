### Manual Setup 

```
minikube start --cpus 2 --memory 12288
git clone https://github.com/adavarski/hadoop-helm-k8s/
cd docker
cp Dockerfile.2.9.0 Dockerfile
docker build -t davarski/hadoop:2.9.0 .
docker login
docker push davarski/hadoop:2.9.0
cd ../helm
vi values.yml
grep "hadoopVer" values.yaml 
hadoopVersion: 2.9.0
grep "image: davarski" values.yaml 
image: davarski/hadoop:2.9.0

kubectl create namespace hadoop
helm install . --name hadoop --namespace hadoop

$ kubectl get pod -nhadoop
NAME                                        READY   STATUS    RESTARTS   AGE
hadoop-hadoop-hdfs-dn-0                     1/1     Running   0          2m
hadoop-hadoop-hdfs-nn-0                     1/1     Running   0          2m
hadoop-hadoop-yarn-nm-0                     0/1     Running   0          2m
hadoop-hadoop-yarn-rm-0                     1/1     Running   0          2m
hadoop-hadoop-zepplin-nn-77b4cf5c5c-z7r97   1/1     Running   0          2m

clean:

$ helm del --purge hadoop
release "hadoop" deleted
$ kubectl delete namespace hadoop
namespace "hadoop" deleted

```
### Jenkins Setup
```
minikube ssh ->  get /etc/kubernetes/admin.conf and change localhost to 192.168.99.109 (minikube ip) 
kubectl --kubeconfig=./admin.conf get po

Setup jenkins pipeline 

Started by user Anastas Dimov
Obtained Jenkinsfile from git https://github.com/adavarski/hadoop-helm-k8s
Running in Durability level: MAX_SURVIVABILITY
[Pipeline] node
Running on Jenkins in /var/lib/jenkins/workspace/hadoop-helm-k8s
[Pipeline] {
[Pipeline] stage
[Pipeline] { (Clone repository)
[Pipeline] checkout
 > git rev-parse --is-inside-work-tree # timeout=10
Fetching changes from the remote Git repository
 > git config remote.origin.url https://github.com/adavarski/hadoop-helm-k8s # timeout=10
Fetching upstream changes from https://github.com/adavarski/hadoop-helm-k8s
 > git --version # timeout=10
 > git fetch --tags --progress https://github.com/adavarski/hadoop-helm-k8s +refs/heads/*:refs/remotes/origin/*
 > git rev-parse refs/remotes/origin/master^{commit} # timeout=10
 > git rev-parse refs/remotes/origin/origin/master^{commit} # timeout=10
Checking out Revision 4a3c4357225f7e29a7257d0bd409c1c5df26f12d (refs/remotes/origin/master)
 > git config core.sparsecheckout # timeout=10
 > git checkout -f 4a3c4357225f7e29a7257d0bd409c1c5df26f12d
Commit message: "Update README.md"
 > git rev-list --no-walk adc640d0b548bdc30e5a7da4d21a28619d80fef4 # timeout=10
[Pipeline] }
[Pipeline] // stage
[Pipeline] stage
[Pipeline] { (Build image)
[Pipeline] sh
+ docker build -t davarski/hadoop .
Sending build context to Docker daemon  271.4kB

Step 1/19 : FROM java:8-jre
 ---> e44d62cf8862
Step 2/19 : ARG HADOOP_VERSION=2.9.0
 ---> Using cache
 ---> 16edf4f28e21
Step 3/19 : ENV KEYS http://www-eu.apache.org/dist/hadoop/common/KEYS
 ---> Using cache
 ---> 02c729502e87
Step 4/19 : ENV KEYS_TMP /tmp/KEYS
 ---> Using cache
 ---> bcbae60bdb90
Step 5/19 : ENV HADOOP_INSTALLER hadoop-$HADOOP_VERSION.tar.gz
 ---> Using cache
 ---> d066083d5de1
Step 6/19 : ENV HADOOP_NAME hadoop-$HADOOP_VERSION
 ---> Using cache
 ---> 01becdf2df0a
Step 7/19 : ENV HADOOP_ASC $HADOOP_INSTALLER.asc
 ---> Using cache
 ---> 8e826a3471a4
Step 8/19 : ENV HADOOP_ASC_URL http://www-eu.apache.org/dist/hadoop/common/$HADOOP_NAME/$HADOOP_ASC
 ---> Using cache
 ---> 01e4142142e2
Step 9/19 : ENV HADOOP_INSTALLER_URL http://ftp.man.poznan.pl/apache/hadoop/common/$HADOOP_NAME/$HADOOP_INSTALLER
 ---> Using cache
 ---> 6cd6780e610c
Step 10/19 : ENV HADOOP_TMP_DIR /tmp/hadoop
 ---> Using cache
 ---> 2ae7ffa54546
Step 11/19 : RUN echo "--$HADOOP_INSTALLER_URL--"
 ---> Using cache
 ---> dae524e5c71e
Step 12/19 : RUN wget --no-check-certificate -c $KEYS -O $KEYS_TMP 2>&1 &&     gpg --import $KEYS_TMP 2>&1 &&     mkdir $HADOOP_TMP_DIR &&     wget --no-check-certificate -c $HADOOP_INSTALLER_URL -O $HADOOP_TMP_DIR/$HADOOP_INSTALLER 2>&1 &&     wget --no-check-certificate -c $HADOOP_ASC_URL -O $HADOOP_TMP_DIR/$HADOOP_ASC 2>&1 &&     tar -xvzf $HADOOP_TMP_DIR/$HADOOP_INSTALLER -C /usr/local &&     rm -rf /tmp/*
 ---> Using cache
 ---> 24ca97f4d71f
Step 13/19 : ENV HADOOP_PREFIX=/usr/local/hadoop     HADOOP_COMMON_HOME=/usr/local/hadoop     HADOOP_HDFS_HOME=/usr/local/hadoop     HADOOP_MAPRED_HOME=/usr/local/hadoop     HADOOP_YARN_HOME=/usr/local/hadoop     HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop     YARN_CONF_DIR=/usr/local/hadoop/etc/hadoop     PATH=${PATH}:/usr/local/hadoop/bin
 ---> Using cache
 ---> 21aa6c6cf84d
Step 14/19 : RUN   cd /usr/local && ln -s ./hadoop-${HADOOP_VERSION} hadoop &&   rm -f ${HADOOP_PREFIX}/logs/*
 ---> Using cache
 ---> 64033306429d
Step 15/19 : WORKDIR $HADOOP_PREFIX
 ---> Using cache
 ---> 4efd8f85a1f6
Step 16/19 : EXPOSE 50010 50020 50070 50075 50090 8020 9000
 ---> Using cache
 ---> 0452c3af9ee0
Step 17/19 : EXPOSE 19888
 ---> Using cache
 ---> 324ce4350a55
Step 18/19 : EXPOSE 8030 8031 8032 8033 8040 8042 8088
 ---> Using cache
 ---> b2a49e031fe0
Step 19/19 : EXPOSE 49707 2122
 ---> Using cache
 ---> 3289e45317b6
Successfully built 3289e45317b6
Successfully tagged davarski/hadoop:latest
[Pipeline] dockerFingerprintFrom
[Pipeline] }
[Pipeline] // stage
[Pipeline] stage
[Pipeline] { (Test image)
[Pipeline] sh
+ docker inspect -f . davarski/hadoop
.
[Pipeline] withDockerContainer
Jenkins does not seem to be running inside a container
$ docker run -t -d -u 123:133 -w /var/lib/jenkins/workspace/hadoop-helm-k8s -v /var/lib/jenkins/workspace/hadoop-helm-k8s:/var/lib/jenkins/workspace/hadoop-helm-k8s:rw,z -v /var/lib/jenkins/workspace/hadoop-helm-k8s@tmp:/var/lib/jenkins/workspace/hadoop-helm-k8s@tmp:rw,z -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** -e ******** davarski/hadoop cat
$ docker top c5acccb5476ae92a03b9eb87d13868d722fc469d8ef69982c9d964ef18fda9f7 -eo pid,comm
[Pipeline] {
[Pipeline] sh
+ echo Tests passed
Tests passed
[Pipeline] }
$ docker stop --time=1 c5acccb5476ae92a03b9eb87d13868d722fc469d8ef69982c9d964ef18fda9f7
$ docker rm -f c5acccb5476ae92a03b9eb87d13868d722fc469d8ef69982c9d964ef18fda9f7
[Pipeline] // withDockerContainer
[Pipeline] }
[Pipeline] // stage
[Pipeline] stage
[Pipeline] { (Push image)
[Pipeline] withEnv
[Pipeline] {
[Pipeline] withDockerRegistry
$ docker login -u davarski -p ******** https://index.docker.io/v1/
WARNING! Using --password via the CLI is insecure. Use --password-stdin.
WARNING! Your password will be stored unencrypted in /var/lib/jenkins/workspace/hadoop-helm-k8s@tmp/56cdb520-4635-4e14-a631-e751dd10860b/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded
[Pipeline] {
[Pipeline] sh
+ docker tag davarski/hadoop index.docker.io/davarski/hadoop:2.9.0
[Pipeline] sh
+ docker push index.docker.io/davarski/hadoop:2.9.0
The push refers to repository [docker.io/davarski/hadoop]
a7c1b182afe6: Preparing
015dc11839c1: Preparing
73ad47d4bc12: Preparing
c22c27816361: Preparing
04dba64afa87: Preparing
500ca2ff7d52: Preparing
782d5215f910: Preparing
0eb22bfb707d: Preparing
a2ae92ffcd29: Preparing
782d5215f910: Waiting
0eb22bfb707d: Waiting
a2ae92ffcd29: Waiting
500ca2ff7d52: Waiting
015dc11839c1: Layer already exists
a7c1b182afe6: Layer already exists
c22c27816361: Layer already exists
73ad47d4bc12: Layer already exists
04dba64afa87: Layer already exists
500ca2ff7d52: Layer already exists
0eb22bfb707d: Layer already exists
782d5215f910: Layer already exists
a2ae92ffcd29: Layer already exists
2.9.0: digest: sha256:1c8ac056ee71591603315987d92a652934311d362ba6a0f8586ee3c68fcb86b9 size: 2207
[Pipeline] }
[Pipeline] // withDockerRegistry
[Pipeline] }
[Pipeline] // withEnv
[Pipeline] stage
[Pipeline] { (Deploy)
[Pipeline] sh
+ kubectl --kubeconfig=./admin.conf create namespace hadoop
namespace/hadoop created
[Pipeline] sh
+ helm --kubeconfig=./admin.conf install helm/ --name hadoop --namespace hadoop
NAME:   hadoop
LAST DEPLOYED: Sun Jan 13 00:04:11 2019
NAMESPACE: hadoop
STATUS: DEPLOYED

RESOURCES:
==> v1beta1/Deployment
NAME                      DESIRED  CURRENT  UP-TO-DATE  AVAILABLE  AGE
hadoop-hadoop-zepplin-nn  1        1        1           0          0s

==> v1beta1/StatefulSet
NAME                   DESIRED  CURRENT  AGE
hadoop-hadoop-hdfs-dn  1        1        0s
hadoop-hadoop-hdfs-nn  1        1        0s
hadoop-hadoop-yarn-nm  2        1        0s
hadoop-hadoop-yarn-rm  1        1        0s

==> v1/Pod(related)
NAME                                       READY  STATUS             RESTARTS  AGE
hadoop-hadoop-hdfs-dn-0                    0/1    ContainerCreating  0         0s
hadoop-hadoop-hdfs-nn-0                    0/1    ContainerCreating  0         0s
hadoop-hadoop-yarn-nm-0                    0/1    ContainerCreating  0         0s
hadoop-hadoop-yarn-rm-0                    0/1    ContainerCreating  0         0s
hadoop-hadoop-zepplin-nn-77b4cf5c5c-5s8mt  0/1    ContainerCreating  0         0s

==> v1beta1/PodDisruptionBudget
NAME                   MIN AVAILABLE  MAX UNAVAILABLE  ALLOWED DISRUPTIONS  AGE
hadoop-hadoop-hdfs-dn  1              N/A              0                    0s
hadoop-hadoop-hdfs-nn  1              N/A              0                    0s
hadoop-hadoop-yarn-nm  1              N/A              0                    0s
hadoop-hadoop-yarn-rm  1              N/A              0                    0s

==> v1/ConfigMap
NAME           DATA  AGE
hadoop-hadoop  8     0s

==> v1/Service
NAME                   TYPE       CLUSTER-IP      EXTERNAL-IP  PORT(S)                     AGE
hadoop-hadoop-hdfs-dn  ClusterIP  None            <none>       9000/TCP,50075/TCP          0s
hadoop-hadoop-hdfs-nn  ClusterIP  None            <none>       9000/TCP,50070/TCP          0s
hadoop-hadoop          ClusterIP  10.111.142.157  <none>       8080/TCP                    0s
hadoop-hadoop-yarn-nm  ClusterIP  None            <none>       8088/TCP,8082/TCP,8042/TCP  0s
hadoop-hadoop-yarn-rm  ClusterIP  None            <none>       8088/TCP                    0s
hadoop-hadoop-yarn-ui  ClusterIP  10.108.196.156  <none>       8088/TCP                    0s


NOTES:
1. You can check the status of HDFS by running this command:
   kubectl exec -n hadoop -it hadoop-hadoop-hdfs-nn-0 -- /usr/local/hadoop/bin/hdfs dfsadmin -report

2. You can list the yarn nodes by running this command:
   kubectl exec -n hadoop -it hadoop-hadoop-yarn-rm-0 -- /usr/local/hadoop/bin/yarn node -list

3. Create a port-forward to the yarn resource manager UI:
   kubectl port-forward -n hadoop hadoop-hadoop-yarn-rm-0 8088:8088 

   Then open the ui in your browser:
   
   open http://localhost:8088

4. You can run included hadoop tests like this:
   kubectl exec -n hadoop -it hadoop-hadoop-yarn-nm-0 -- /usr/local/hadoop/bin/hadoop jar /usr/local/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-2.9.0-tests.jar TestDFSIO -write -nrFiles 5 -fileSize 128MB -resFile /tmp/TestDFSIOwrite.txt

5. You can list the mapreduce jobs like this:
   kubectl exec -n hadoop -it hadoop-hadoop-yarn-rm-0 -- /usr/local/hadoop/bin/mapred job -list

6. This chart can also be used with the zeppelin chart
    helm install --namespace hadoop --set hadoop.useConfigMap=true,hadoop.configMapName=hadoop-hadoop stable/zeppelin

7. You can scale the number of yarn nodes like this:
   helm upgrade hadoop --set yarn.nodeManager.replicas=4 stable/hadoop

   Make sure to update the values.yaml if you want to make this permanent.

[Pipeline] }
[Pipeline] // stage
[Pipeline] }
[Pipeline] // stage
[Pipeline] }
[Pipeline] // node
[Pipeline] End of Pipeline
Finished: SUCCESS

```
# Hadoop Chart

[Hadoop](https://hadoop.apache.org/) is a framework for running large scale distributed applications.

This chart is primarily intended to be used for YARN and MapReduce job execution where HDFS is just used as a means to transport small artifacts within the framework and not for a distributed filesystem. Data should be read from cloud based datastores such as Google Cloud Storage, S3 or Swift.

## Chart Details

## Installing the Chart

To install the chart with the release name `hadoop` that utilizes 50% of the available node resources:

```
helm install . --name hadoop --set image=davarski/hadoop:2.9.0
$ helm install . --name hadoop-1.0.0 $(stable/hadoop/tools/calc_resources.sh 50) --set image.tag=hadoop-1.0.0
```    

port fordwar to the Yarn UI    
```
$ kubectl port-forward hadoop-hadoop-yarn-rm-0 8088:8088
```

port fordwar to the Zepplin UI    
```
$ kubectl --namespace hadoop get pods 
$ kubectl --namespace hadoop port-forward hadoop-hadoop-zepplin-nn-{unique-value} 8080:8080
```

> Note that you need at least 2GB of free memory per NodeManager pod, if your cluster isn't large enough, not all pods will be scheduled.

The optional [`calc_resources.sh`](./tools/calc_resources.sh) script is used as a convenience helper to set the `yarn.numNodes`, and `yarn.nodeManager.resources` appropriately to utilize all nodes in the Kubernetes cluster and a given percentage of their resources. For example, with a 3 node `n1-standard-4` GKE cluster and an argument of `50`, this would create 3 NodeManager pods claiming 2 cores and 7.5Gi of memory.

### Persistence

To install the chart with persistent volumes:

```
$ helm install --name hadoop . \
  --set persistence.nameNode.enabled=true \
  --set persistence.nameNode.storageClass=standard \
  --set persistence.dataNode.enabled=true \
  --set persistence.dataNode.storageClass=standard \
  --set image.tag=hadoop-1.0.0
```

> Change the value of `storageClass` to match your volume driver. `standard` works for Google Container Engine clusters.

## Configuration

The following table lists the configurable parameters of the Hadoop chart and their default values.

| Parameter                                         | Description                                                                        | Default                                                          |
| ------------------------------------------------- | -------------------------------                                                    | ---------------------------------------------------------------- |
| `image`                                           | Hadoop image ([source](https://github.com/Comcast/kube-yarn/tree/master/image))    | `danisla/hadoop:{VERSION}`                                       |
| `imagePullPolicy`                                 | Pull policy for the images                                                         | `IfNotPresent`                                                   |
| `hadoopVersion`                                   | Version of hadoop libraries being used                                              | `{VERSION}`                                                      |
| `antiAffinity`                                    | Pod antiaffinity, `hard` or `soft`                                                 | `hard`                                                           |
| `hdfs.nameNode.pdbMinAvailable`                   | PDB for HDFS NameNode                                                              | `1`                                                              |
| `hdfs.nameNode.resources`                         | resources for the HDFS NameNode                                                    | `requests:memory=256Mi,cpu=10m,limits:memory=2048Mi,cpu=1000m`   |
| `hdfs.dataNode.replicas`                          | Number of HDFS DataNode replicas                                                   | `1`                                                              |
| `hdfs.dataNode.pdbMinAvailable`                   | PDB for HDFS DataNode                                                              | `1`                                                              |
| `hdfs.dataNode.resources`                         | resources for the HDFS DataNode                                                    | `requests:memory=256Mi,cpu=10m,limits:memory=2048Mi,cpu=1000m`   |
| `yarn.resourceManager.pdbMinAvailable`            | PDB for the YARN ResourceManager                                                   | `1`                                                              |
| `yarn.resourceManager.resources`                  | resources for the YARN ResourceManager                                             | `requests:memory=256Mi,cpu=10m,limits:memory=2048Mi,cpu=1000m`   |
| `yarn.nodeManager.pdbMinAvailable`                | PDB for the YARN NodeManager                                                       | `1`                                                              |
| `yarn.nodeManager.replicas`                       | Number of YARN NodeManager replicas                                                | `2`                                                              |
| `yarn.nodeManager.parallelCreate`                 | Create all nodeManager statefulset pods in parallel (K8S 1.7+)                     | `false`                                                          |
| `yarn.nodeManager.resources`                      | Resource limits and requests for YARN NodeManager pods                             | `requests:memory=2048Mi,cpu=1000m,limits:memory=2048Mi,cpu=1000m`|
| `persistence.nameNode.enabled`                    | Enable/disable persistent volume                                                   | `false`                                                          | 
| `persistence.nameNode.storageClass`               | Name of the StorageClass to use per your volume provider                           | `-`                                                              |
| `persistence.nameNode.accessMode`                 | Access mode for the volume                                                         | `ReadWriteOnce`                                                  |
| `persistence.nameNode.size`                       | Size of the volume                                                                 | `50Gi`                                                           |
| `persistence.dataNode.enabled`                    | Enable/disable persistent volume                                                   | `false`                                                          | 
| `persistence.dataNode.storageClass`               | Name of the StorageClass to use per your volume provider                           | `-`                                                              |
| `persistence.dataNode.accessMode`                 | Access mode for the volume                                                         | `ReadWriteOnce`                                                  |
| `persistence.dataNode.size`                       | Size of the volume                                                                 | `200Gi`                                                          |
