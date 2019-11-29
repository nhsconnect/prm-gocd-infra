#!/bin/bash -e

if hash docker 2>/dev/null; then
  echo "Docker aleady installed"
else
  sudo yum update -y
  sudo amazon-linux-extras install -y docker
  sudo service docker start
  sudo usermod -a -G docker ec2-user
fi

sudo yum install -y python python-pip
