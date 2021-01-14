#!/bin/bash -e

AGENT_IMAGE_VERSION=${GOCD_AGENT_IMAGE_TAG}
GOCD_ENVIRONMENT=${GOCD_ENVIRONMENT}
AWS_REGION=${AWS_REGION}
AGENT_RESOURCES=${AGENT_RESOURCES}

if hash docker 2>/dev/null; then
  echo "Docker aleady installed"
else
  sudo yum update -y
  sudo amazon-linux-extras install -y docker
  sudo service docker start
  sudo usermod -a -G docker ec2-user
fi

sudo yum install -y python python-pip

mkdir -p /var/go-agent/docker /var/go-agent/workspace /var/go-agent/godata

# Relies on VM having an instance profile with gocd role which has permissions to pull from ECR
# login into AWS ECR registry
echo y | eval $(aws ecr get-login --region eu-west-2 --no-include-email)

docker run -d \
  --restart=always \
  --net host \
  --name gocd-agent \
  --privileged \
  --cap-add SYS_ADMIN \
  --security-opt apparmor:unconfined \
  -e AGENT_HOSTNAME=$HOSTNAME \
  -e AGENT_RESOURCES=$AGENT_RESOURCES \
  -e GOCD_ENVIRONMENT=$GOCD_ENVIRONMENT \
  -e AWS_REGION=$AWS_REGION \
  -e DOCKER_OPTS="--storage-driver overlay2" \
  -e GO_SERVER_URL="https://$GOCD_ENVIRONMENT.gocd.patient-deductions.nhs.uk:8153/go" \
  -e AGENT_BOOTSTRAPPER_ARGS="-sslVerificationMode NONE" \
  -e AWS_SECRET_STORE_PATH="repo/$GOCD_ENVIRONMENT/user-input" \
  -e GOCD_SKIP_SECRETS="true" \
  -e SECRET_STORE="aws" \
  -v "/var/go-agent/godata:/godata" \
  -v "/var/go-agent/docker:/var/lib/docker" \
  -v "/var/go-agent/workspace:/var/lib/go-agent/pipelines" \
  -v "/etc/localtime:/etc/localtime:ro" \
  -v "/lib/modules:/lib/modules:ro" \
  -v "/sys/fs/cgroup:/sys/fs/cgroup" \
  327778747031.dkr.ecr.eu-west-2.amazonaws.com/gocd-agent:$AGENT_IMAGE_VERSION
