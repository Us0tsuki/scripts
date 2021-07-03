# Install the latest version driver of your video card
apt install nvidia-driver-460

# Install nvidia-docker 2
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
   && curl -s -L -k https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - \
   && curl -s -L -k https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

touch -a /etc/apt/apt.conf.d/999proxy
cat <<EOF | sudo tee -a /etc/apt/apt.conf.d/999proxy
Acquire::https::nvidia.github.io::Verify-Peer false;
Acquire::https::apt.kubernetes.io::Verify-Peer false;
Acquire::https::packages.cloud.google.com::Verify-Peer false;
EOF
sudo apt update

sudo apt install -y nvidia-docker2

# Validate Successful installation(docker 19.03 and later)
sudo docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi

nvidia-docker run myimage