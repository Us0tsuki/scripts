#Pre-req: Add node to security group(master/node).

# Display required sudo docker image list(depending on current kubelet and kubectl version)
kubeadm config images list
k8s.gcr.io/kube-apiserver:v1.15.0
k8s.gcr.io/kube-controller-manager:v1.15.0
k8s.gcr.io/kube-scheduler:v1.15.0
k8s.gcr.io/kube-proxy:v1.15.0
k8s.gcr.io/pause:3.4.1
k8s.gcr.io/etcd:3.4.13-0
k8s.gcr.io/coredns/coredns:v1.8.0


# All images other than coredns can be pulled from aliyun registry(registry.aliyuncs.com/google_containers/ or registry.cn-hangzhou.aliyuncs.com/google_containers/)
sudo docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-apiserver:v1.15.0
sudo docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-apiserver:v1.15.0 k8s.gcr.io/kube-apiserver:v1.15.0
sudo docker rmi registry.cn-hangzhou.aliyuncs.com/google_containers/kube-apiserver:v1.15.0

sudo docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-controller-manager:v1.15.0
sudo docker tag 10.174.72.80:6000/registry.cn-hangzhou.aliyuncs.com/google_containers/kube-controller-manager:v1.15.0 k8s.gcr.io/kube-controller-manager:v1.15.0
sudo docker rmi 10.174.72.80:6000/registry.cn-hangzhou.aliyuncs.com/google_containers/kube-controller-manager:v1.15.0

sudo docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-scheduler:v1.15.0
sudo docker tag 10.174.72.80:6000/registry.cn-hangzhou.aliyuncs.com/google_containers/kube-scheduler:v1.15.0 k8s.gcr.io/kube-scheduler:v1.15.0
sudo docker rmi 10.174.72.80:6000/registry.cn-hangzhou.aliyuncs.com/google_containers/kube-scheduler:v1.15.0

sudo docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-proxy:v1.15.0
sudo docker tag 10.174.72.80:6000/registry.cn-hangzhou.aliyuncs.com/google_containers/kube-proxy:v1.15.0 k8s.gcr.io/kube-proxy:v1.15.0
sudo docker rmi 10.174.72.80:6000/registry.cn-hangzhou.aliyuncs.com/google_containers/kube-proxy:v1.15.0

sudo docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.1
sudo docker tag 10.174.72.80:6000/registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.1 k8s.gcr.io/pause:3.1
sudo docker rmi 10.174.72.80:6000/registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.1

sudo docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/etcd:3.3.10
sudo docker tag 10.174.72.80:6000/registry.cn-hangzhou.aliyuncs.com/google_containers/etcd:3.3.10 k8s.gcr.io/etcd:3.3.10
sudo docker rmi 10.174.72.80:6000/registry.cn-hangzhou.aliyuncs.com/google_containers/etcd:3.3.10

# Core dns could be pulled from /coredns in sudo dockerhub
sudo docker pull coredns/coredns:1.3.1
sudo docker tag 10.174.72.80:6000/coredns/coredns:1.3.1 k8s.gcr.io/coredns:1.3.1 
sudo docker rmi 10.174.72.80:6000/coredns/coredns:1.3.1



kubeadm config print init-defaults

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/bc79dd1505b0c8681ece4de4c0d86c5cd2643275/Documentation/kube-flannel.yml

kubeadm init --kubernetes-version=1.15.0 --pod-network-cidr=10.244.0.0/16

# For regular user
mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
 
# For root user
cat <<EOF | sudo tee /etc/profile.d/k8s-config.sh
export KUBECONFIG=/etc/kubernetes/admin.conf
EOF

kubectl get pods --all-namespaces

wget --no-check-certificate https://raw.githubusercontent.com/coreos/flannel/bc79dd1505b0c8681ece4de4c0d86c5cd2643275/Documentation/kube-flannel.yml
kubectl apply -f kube-flannel.yml

# 
curl -k https://localhost:6443/livez?verbose

[preflight] Running pre-flight checks
        [WARNING Hostname]: hostname "node" could not be reached
        [WARNING Hostname]: hostname "node": lookup node on 10.72.255.100:53: no such host

[upload-certs] Skipping phase. Please see --upload-certs

[bootstrap-token] Using token: abcdef.0123456789abcdef

NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   17h

kubeadm join 10.173.74.74:6443 --token mgqvfd.y69110ezqoiiy8qo --discovery-token-ca-cert-hash sha256:a85902c519be9ff04de651ecec429a9f10c969e47de214d412e5a3da0f32a44b

在所有节点安装flannel，kube-proxy和pause包



https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.45.0/deploy/static/provider/cloud/deploy.yaml

# Install ingress-nginx related images on all nodes
# 1. Download images on 64 or other sudo docker env with proxy, then push to registry on 64.
sudo docker pull pollyduan/ingress-nginx-controller:v0.45.0
sudo docker tag pollyduan/ingress-nginx-controller:v0.45.0 10.174.72.80:6000/k8s.gcr.io/ingress-nginx/controller:v0.45.0
sudo docker push 10.174.72.80:6000/k8s.gcr.io/ingress-nginx/controller:v0.45.0

sudo docker pull jettech/kube-webhook-certgen:v1.5.1
sudo docker tag jettech/kube-webhook-certgen:v1.5.1 10.174.72.80:6000/sudo docker.io/jettech/kube-webhook-certgen:v1.5.1
sudo docker push 10.174.72.80:6000/sudo docker.io/jettech/kube-webhook-certgen:v1.5.1

# 2. 


