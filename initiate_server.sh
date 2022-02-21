#!/bin/bash

# allow my laptop's public key for SSH
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDKCI6j1VpcMgYLIxnE05BqXJnm/gcPUluURx6mrorSp/BVfs8K7Sdhn5gD/PphxhYohcJ+zA+u7yweg7/SJ1KUL+oDypH5vtIRCav13lyNYIGNvxevXAOwb6Yy7jYX5Qd4ZHCAF6c/9upx1ewCBj49W74CKvIwjEws3YRpk/cW9pmRxJ0nQq0dDlArqc734L8XkRpoSuwdKy65Zy0LViPRgYfwXezt/vS4XSGkFdYsN4aMjBAfAxESy4/b1oOcBbEptiJDBQugJjYPEAKXW8SVLtM+0Zw8TDJrWnd8ruzFuoP7lHIUOq/CNWDrrzzlmsU7noQfxGhwDhE5EuNc5ZW5 subhayu@FFT-ThinkPad-L490" >> /home/ubuntu/.ssh/authorized_keys
chown ubuntu: /home/ubuntu/.ssh/authorized_keys
chmod 0600 /home/ubuntu/.ssh/authorized_keys

# install docker
apt-get -y remove docker docker-engine docker.io containerd runc
apt-get -y update
apt-get -y install \
    apt-transport-https \
    software-properties-common \
    git \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
apt-get -y update
apt-get -y install docker-ce docker-ce-cli containerd.io python3-pip
service docker start

# install docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /bin/docker-compose