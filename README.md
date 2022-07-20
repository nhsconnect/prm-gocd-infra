# prm-gocd-infra

Setup of GoCD deployment for NHS repository team.

Server dashboard is accessible at `https://prod.gocd.patient-deductions.nhs.uk` only over VPN. You need to authenticate using Github OAuth.

# Architecture

GoCD consists of server and agents.

Server data is stored in RDS database. Build artifacts are stored on a EC2 volume.

The server is behind a proxy facing the internet.

There are several agents running in a dedicated VPC. These are general-purpose agents to be used for building code or docker images.

Other agents can be deployed in specific networks. The `remote-agents-module` terraform module can be used to provision agents in other subnets.

## Tools on agents

Each agent has Docker and Dojo available, which makes it possible to build any project as long as you produce a docker image with required tools first. For more details see the [Dojo readme](https://github.com/kudulab/dojo).

A complete spec of the agent tools is defined by [Kudulab's GoCD Agent DockerDocker image](https://github.com/kudulab/docker-kudu-gocd-agent) which contains the actual docker file.


# Deployment/Lifecycle

## Access to AWS

In order to get sufficient access to work with terraform or AWS CLI:

Make sure to unset the AWS variables:
```
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN
```

As a note, the following set-up is based on the README of assume-role [tool](https://github.com/remind101/assume-role)

Set up a profile for each role you would like to assume in `~/.aws/config`, for example:

```
[profile default]
region = eu-west-2
output = json

[profile admin]
region = eu-west-2
role_arn = <role-arn>
mfa_serial = <mfa-arn>
source_profile = default
```

The `source_profile` needs to match your profile in `~/.aws/credentials`.
```
[default]
aws_access_key_id = <your-aws-access-key-id>
aws_secret_access_key = <your-aws-secret-access-key>
```

## Assume role with elevated permissions

### Install `assume-role` locally:
`brew install remind101/formulae/assume-role`

Run the following command with the profile configured in your `~/.aws/config`:

`assume-role admin`

### Run `assume-role` with dojo:
Run the following command with the profile configured in your `~/.aws/config`:

`eval $(dojo "echo <mfa-code> | assume-role admin")`

Run the following command to confirm the role was assumed correctly:

`aws sts get-caller-identity`

## Environments

* `NHS_ENVIRONMENT` refers to the aws environment - `dev`, `test`, `pre-prod` etc.
* `GOCD_ENVIRONMENT` refers to GoCD environment specifically - 
GoCD is always in `prod`, however it is within the `ci` AWS account.

# VPN

## Generating VPN client keys

1. [Gain access to AWS as described above](#Access-to-AWS)
2. Generate GoCD VPN client configuration:
```
GOCD_ENVIRONMENT=prod ./tasks generate_vpn_client_crt <your-first-name.your-last-name>
```

## AWS SSM Parameters Design Principles

When creating the new ssm keys, please follow the agreed convention as per the design specified below:

* all parts of the keys are lower case
* the words are separated by dashes (`kebab case`)
* `env` is optional

### Design:
Please follow this design to ensure the ssm keys are easy to maintain and navigate through:

| Type               | Design                                  | Example                                               |
| -------------------| ----------------------------------------| ------------------------------------------------------|
| **User-specified** |`/repo/<env>?/user-input/`               | `/repo/${var.environment}/user-input/db-username`     |
| **Auto-generated** |`/repo/<env>?/output/<name-of-git-repo>/`| `/repo/output/prm-deductions-base-infra/root-zone-id` |


## Deployment

You can pick which deployment to manage by setting environment variable `GOCD_ENVIRONMENT`.
To make changes in production, set
```
export GOCD_ENVIRONMENT=prod
```

To generate database credentials:
```
./tasks create_secrets
```

To make changes in this deployment, run:
```
./tasks tf_plan create
```
Review the terraform plan and apply with:
```
./tasks tf_apply
```

At this point EC2 instance should exist.

Next step is to install GoCD software on it. To achieve this, you need to use _ssh port forwarding_ - known also as _ssh tunneling_ - to be able to connect your local machine to the remote server/EC2 via VPN.

To achieve this, you have to execute `./tasks create_ssh_tunnel`, that start a tunnel to the GoCD EC2 instance.

Now you should be able to provision GoCD server using `./tasks provision` opening another console/terminal session.

Updating only the agents can be done with:
```
GOCD_ENVIRONMENT=prod ./tasks tf_plan_agents create
GOCD_ENVIRONMENT=prod ./tasks tf_apply
```

Agent's images are built and pushed manually, dockerfiles are versioned at [nhsconnect/prm-docker-gocd-agent](https://github.com/nhsconnect/prm-docker-gocd-agent).

## Deployment from linux

From linux (Ubuntu 18.0.4 LTS tested) the network setup is slightly differnt and SSH forwarding does not work out of the box,
neither does DNS resolution over VPN. Simplest setup is to use direct networking without the tunnel requiring these changes (currently requiring manual change, scripts automated for use on Macs):
- use `Dojofile-ansible-linux` to fix the DNS
- instead of `docker.host.internal` use `<gocd env>.gocd.patient-deductions.nhs.uk`
- don't use the `-p / -P 2222` switches, go direct to SSH port 22

## Google Chat notification setup for GoCD
- `git clone https://github.com/susmithasrimani/gocd-google-chat-build-notifier.git`
- `cd gocd-google-chat-build-notifier`
- `./gradlew uberJar`
- Make sure you can `ssh` into GoCD server
- `scp build/libs/gocd-google-chat-build-notifier-uber.jar <user>@<gocd-server-ip>:/var/gocd-data/data/plugins/external/`
- Go back to `prm-gocd-infra`
- Make sure you've assumed the AWS role with elevated permissions
- `./tasks provision`
- Reboot the GoCD server EC2 instance, preferably by restarting docker instance on the server you `ssh`'ed into
- Go to [GoCD plugins page](https://prod.gocd.patient-deductions.nhs.uk/go/admin/plugins)
- Click on the cogwheel next to the Google Chat Build Notifier plugin
- Paste the Google Chat webhook token into `Webhook URL` field. You can find Google Chat webhook token in the `NHS - PRM Build Failures` room at `Manage webhooks` option.

## TODO & Manual steps

Some more automation to do:
 - SSL certs are currently issued manually from workstation and sent over to the GoCD server. It could be automated on the GoCD machine.
 - Connecting GoCD analytics to the RDS requires to put plugin settings via the UI
 - Agent's auto-registration key was placed in SSM store manually. This is a one-time operation.
 - Agents could be placed behind a NAT.

## Troubleshooting and Common Issues
- When gocd server has disk/memory related issue to release some disk space `docker system prune`
- To run the gocd server container manually `docker run --detach -p "8153:8153" -p "8154:8154" --env GCHAT_NOTIFIER_CONF_PATH=/home/go/gchat_notif.conf --env GOCD_SERVER_JVM_OPTS="-Dlog4j2.formatMsgNoLookups=true" --volume "/var/gocd-data/data:/godata" --volume "/var/gocd-data/go-working-dir:/go-working-dir" --volume "/var/gocd-data/home:/home/go" --name server gocd-server:latest`