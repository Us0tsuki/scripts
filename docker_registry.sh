--- Docker Registry Initialization ---
cd /etc/docker
mkdir auth
htpasswd -Bbn octopus Huawei@123 > auth/htpasswd

docker run -d \
  -p 5000:5000 \
  --restart=always \
  --name octopus-registry \
  -v "$(pwd)"/auth:/auth \
  -e "REGISTRY_AUTH=htpasswd" \
  -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
  -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
  registry:2.7.1
