#!/bin/bash -e

# Remove insecure CBC ciphers from sshd config
sudo sshd -T | grep ciphers | sudo sed -e "s/\(3des-cbc\|aes128-cbc\|aes192-cbc\|aes256-cbc\|blowfish-cbc\|cast128-cbc\)\,\?//g" | sudo tee -a /etc/ssh/sshd_config

if hash docker 2>/dev/null; then
  echo "Docker already installed"
else
  sudo yum update -y
  sudo amazon-linux-extras install -y docker
  sudo service docker start
  sudo systemctl enable docker
  sudo usermod -a -G docker ec2-user
fi

sudo yum install -y python python-pip
