#!/usr/bin/env bash

apt-get update
apt-get -y install figlet jq make wget
apt install -y python3-pip
python3 -m pip install awscli

curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

sudo wget https://github.com/derailed/k9s/releases/download/v0.21.7/k9s_Linux_x86_64.tar.gz && tar zxf k9s_Linux_x86_64.tar.gz
sudo chmod +x k9s
sudo mv k9s /usr/local/bin

aws eks update-kubeconfig --name=${cluster_name} --region=${region}
${user_data}