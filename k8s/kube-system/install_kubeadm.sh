### Install Kubeadm ###

#!/bin/sh
swapoff -a  
sed -i '/ swap / s/^/#/' /etc/fstab

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

# Install and Config Docker
apt install docker.io
systemctl enable docker
mkdir -p /etc/systemd/system/docker.service.d
echo "[Service]
Environment=\"HTTP_PROXY=http://10.174.72.64:3128\"
Environment=\"HTTPS_PROXY=http://10.174.72.64:3128\"
Environment=\"NO_PROXY=localhost,127.0.0.0/8,10.0.0.0/8,*.huawei.com,*.huaweicloud.com\"" >> /etc/systemd/system/docker.service.d/proxy.conf

cat <<EOF | sudo tee /etc/docker/daemon.json
{
   "exec-opts": ["native.cgroupdriver=systemd"],
   "log-driver": "json-file",
   "log-opts": {
       "max-size": "100m"
   },
   "storage-driver": "overlay2",
   "graph": "/var/lib/docker",
   "live-restore": true,
   "experimental": true,
   "insecure-registries": [
       "10.174.72.64:5000",
       "quay.io",
       "registry.cn-hangzhou.aliyuncs.com",
       "registry.aliyuncs.com",
       "mirror.ccs.tencentyun.com",
       "swr.cn-north-1.myhuaweicloud.com",
       "registry-cbu.huawei.com",
       "registry.huawei.com",
       "swr.cn-north-5.myhuaweicloud.com",
       "registry-1.docker.io",
       "rnd-dockerhub.huawei.com",
       "swr.cn-east-212.hdmap.myhuaweicloud.com",
       "swr.cn-north-4.myhuaweicloud.com"
   ],
   "registry-mirrors": [
       "https://registry.docker-cn.com",
       "https://docker.mirrors.ustc.edu.cn",
       "http://hub-mirror.c.163.com",
       "https://cr.console.aliyun.com/"
   ]
}
EOF
systemctl daemon-reload
systemctl restart docker.service
systemctl status docker.service

cat <<EOF | sudo tee -a /etc/apt/apt.conf.d/999proxy
Acquire::https::apt.kubernetes.io::Verify-Peer false;
Acquire::https::packages.cloud.google.com::Verify-Peer false;
EOF

apt update
apt install -y apt-transport-https ca-certificates curl

curl -k -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

apt update
apt install -y kubelet=1.15.0-00 kubeadm=1.15.0-00 kubectl=1.15.0-00
apt-mark hold kubelet kubeadm kubectl

### Create k8s cluster
#Pre-req: Add node to security group(master/node).

# Display required docker image list(depending on current kubelet and kubectl version)
kubeadm config images list
# k8s.gcr.io/kube-apiserver:v1.21.0
# k8s.gcr.io/kube-controller-manager:v1.21.0
# k8s.gcr.io/kube-scheduler:v1.21.0
# k8s.gcr.io/kube-proxy:v1.21.0
# k8s.gcr.io/pause:3.4.1
# k8s.gcr.io/etcd:3.4.13-0
# k8s.gcr.io/coredns/coredns:v1.8.0

