#!/bin/sh

# Config Huawei deb source
sudo cp -p /etc/apt/sources.list /etc/apt/sources.list.backup

echo "deb http://mirrors.tools.huawei.com/ubuntu/ bionic main multiverse restricted universe
deb http://mirrors.tools.huawei.com/ubuntu/ bionic-backports main multiverse restricted universe
deb http://mirrors.tools.huawei.com/ubuntu/ bionic-proposed main multiverse restricted universe
deb http://mirrors.tools.huawei.com/ubuntu/ bionic-security main multiverse restricted universe
deb http://mirrors.tools.huawei.com/ubuntu/ bionic-updates main multiverse restricted universe
deb-src http://mirrors.tools.huawei.com/ubuntu/ bionic main multiverse restricted universe
deb-src http://mirrors.tools.huawei.com/ubuntu/ bionic-backports main multiverse restricted universe
deb-src http://mirrors.tools.huawei.com/ubuntu/ bionic-proposed main multiverse restricted universe
deb-src http://mirrors.tools.huawei.com/ubuntu/ bionic-security main multiverse restricted universe
deb-src http://mirrors.tools.huawei.com/ubuntu/ bionic-updates main multiverse restricted universe" | sudo tee /etc/apt/sources.list

# Config Proxy
cat <<EOF | sudo tee /etc/apt/apt.conf.d/9999proxy
Acquire::http::Proxy "http://10.173.74.46:3128";
EOF

export http_proxy=http://10.173.74.46:3128
export https_proxy=http://10.173.74.46:3128

# Install all dependencies
sudo apt update
sudo apt install \
	apt-transport-https \
	ca-certificates \
	curl \
	gnupg \
	lsb-release

# Download gpg key and add deb source
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Trust all source
cat <<EOF | sudo tee -a /etc/apt/apt.conf.d/999trust-all
Acquire::https::Verify-Peer "false";
Acquire::https::Verify-Host "false";
EOF

# Install docker
sudo apt update
apt-cache madison docker-ce
sudo apt install docker-ce=5:18.09.9~3-0~ubuntu-bionic docker-ce-cli=5:18.09.9~3-0~ubuntu-bionic containerd.io
systemctl enable docker

# Config registry mirrors and runtime for nvidia-docker2(gpu nodes only)
cat <<EOF | sudo tee /etc/docker/daemon.json
{	
    "runtimes": {
		"nvidia": {
			"path": "nvidia-container-runtime",
			"runtimeArgs": []
		}
	},
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

# Config Proxy for docker
sudo mkdir -p /etc/systemd/system/docker.service.d

cat <<EOF | sudo tee /etc/systemd/system/docker.service.d/proxy.conf
[Service]
Environment=\"HTTP_PROXY=http://127.0.0.1:3128\"
Environment=\"HTTPS_PROXY=http://127.0.0.1:3128\"
Environment=\"NO_PROXY=localhost,127.0.0.0/8,10.0.0.0/8,*.huawei.com,*.huaweicloud.com\"
EOF

sudo systemctl daemon-reload
sudo systemctl restart docker.service
