#!/bin/bash -e

AGENT_IMAGE_VERSION=${GOCD_AGENT_IMAGE_TAG}
GOCD_ENVIRONMENT=${GOCD_ENVIRONMENT}
AWS_REGION=${AWS_REGION}
AGENT_RESOURCES=${AGENT_RESOURCES}

sudo yum update -y

#Removing ssh service
sudo yum erase amazon-ssm-agent --assumeyes
sudo systemctl stop sshd
sudo systemctl disable sshd
yes | sudo yum erase openssh-server

if hash docker 2>/dev/null; then
  echo "Docker already installed"
else
  sudo amazon-linux-extras install -y docker
  sudo service docker start
  sudo usermod -a -G docker ec2-user
fi

# Configure Cloudwatch agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
rpm -U ./amazon-cloudwatch-agent.rpm

# Use cloudwatch config from SSM
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
-a fetch-config \
-m ec2 \
-c ssm:${SSM_CLOUDWATCH_CONFIG} -s

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
  -e AGENT_AUTO_REGISTER_HOSTNAME=$HOSTNAME \
  -e AGENT_AUTO_REGISTER_RESOURCES=$AGENT_RESOURCES \
  -e AWS_REGION=$AWS_REGION \
  -e DOCKER_OPTS="--storage-driver overlay2" \
  -e GO_SERVER_URL="https://$GOCD_ENVIRONMENT.gocd.patient-deductions.nhs.uk/go" \
  -e SECRET_STORE=aws \
  -e AWS_SECRET_STORE_PATH=repo/$GOCD_ENVIRONMENT/user-input/external \
  -v "/var/go-agent/godata:/godata" \
  -v "/var/go-agent/docker:/var/lib/docker" \
  -v "/etc/localtime:/etc/localtime:ro" \
  -v "/lib/modules:/lib/modules:ro" \
  -v "/sys/fs/cgroup:/sys/fs/cgroup" \
  327778747031.dkr.ecr.eu-west-2.amazonaws.com/gocd-agent:$AGENT_IMAGE_VERSION