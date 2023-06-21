# prm-gocd-infra

Setup of [GoCD](https://www.gocd.org/) deployment for NHS Repo Team.

The server is accessible at `https://prod.gocd.patient-deductions.nhs.uk` via VPN. You will need to authenticate
using GitHub.

## Architecture

GoCD consists of a server and agents. The server data is stored in an [RDS database](https://aws.amazon.com/rds/) and
build artifacts are stored on an
[EC2 volume](https://aws.amazon.com/ec2/).

The server is behind a proxy facing the internet. There are several agents running in a dedicated virtual private
cloud (VPC). These are general-purpose agents to be used for building code or
[Docker](https://www.docker.com/) images. Other agents can be deployed in specific networks. The `remote-agents-module`
terraform module can be used to provision agents in other subnets.

## Agent Tools

Each agent has Docker and [Dojo](https://github.com/kudulab/dojo) available. This makes it possible to build any project
as long as you produce a Docker image with the required tools first. For more details, see
the [Dojo README](https://github.com/kudulab/dojo/blob/master/README.md).

A complete spec of the agent tools is defined
by [Kudulab's GoCD Agent Docker image](https://github.com/kudulab/docker-kudu-gocd-agent) which contains the actual
Docker file.

## AWS Access

This section details how to obtain sufficient access to work with [Terraform](https://www.terraform.io/)
or [AWS CLI](https://aws.amazon.com/cli/).

_Note: This is based on the README of the [assume-role tool](https://github.com/remind101/assume-role)._

### 1. Unset AWS Variables

```
  unset AWS_ACCESS_KEY_ID
  unset AWS_SECRET_ACCESS_KEY
  unset AWS_SESSION_TOKEN
```

### 2. Set Up AWS Profiles

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

The `source_profile` needs to match your profile in `~/.aws/credentials`, for example:

```
[default]
aws_access_key_id = <your-aws-access-key-id>
aws_secret_access_key = <your-aws-secret-access-key>
```

### 3. Install `assume-role`

Install `assume-role` via [Homebrew](https://brew.sh/): `brew install remind101/formulae/assume-role`.

### 4. Set Up `assume-role` With Elevated Permissions

Run the following commands with the profile configured in your `~/.aws/config`:

- Locally: `assume-role admin`
- Dojo: `eval $(dojo "echo <mfa-code> | assume-role admin")`

Run the following command to confirm the role was assumed correctly: `aws sts get-caller-identity`.

## Deployment & Lifecycle

### Environments

- `NHS_ENVIRONMENT` refers to the AWS envs: `dev`, `test`, `pre-prod`, etc.
- `GOCD_ENVIRONMENT` refers to GoCD env specifically
    - GoCD is always in `prod`, however it is within the `ci` AWS account.

### VPN

VPN client keys can be generated via the following steps:

1. [Gain access to AWS as described above](#AWS-Access)
2. Generate GoCD VPN client configuration via the following command:

```
GOCD_ENVIRONMENT=prod ./tasks generate_vpn_client_crt <your-first-name.your-last-name>
```

### [AWS SSM](https://docs.aws.amazon.com/systems-manager/latest/userguide/ssm-agent.html) Parameters Design Principles

#### Principles

When creating the new SSM keys, please follow the agreed convention as per the design specified below:

- All parts of the keys are lowercase
- The words are separated by dashes (`kebab-case`)
- `env` is optional

#### Design

Please follow this design to ensure the SSM keys are easy to maintain and navigate through:

| Type               | Design                                    | Example                                               |
|--------------------|-------------------------------------------|-------------------------------------------------------|
| **User-specified** | `/repo/<env>?/user-input/`                | `/repo/${var.environment}/user-input/db-username`     |
| **Auto-generated** | `/repo/<env>?/output/<name-of-git-repo>/` | `/repo/output/prm-deductions-base-infra/root-zone-id` |

### Deployment

You can pick which deployment to manage by setting environment variable `GOCD_ENVIRONMENT`. To make changes in `prod`,
set the following:

```
export GOCD_ENVIRONMENT=prod
```

#### Generate DB Credentials

```
./tasks create_secrets
```

#### Make Changes To This Deployment

```
./tasks tf_plan create
```

#### Review The Terraform Plan & Apply:

```
./tasks tf_apply
```

At this point EC2 instance should exist.

#### Installing GoCD

You need to use SSH port forwarding (AKA SSH tunneling) to be able to connect your local machine to the remote
server/EC2 via the VPN. To achieve this, execute: `./tasks create_ssh_tunnel`. This starts a tunnel to the GoCD EC2
instance.

#### Provisioning GoCD

Now you should be able to provision the GoCD server using: `./tasks provision`. This opens another console/terminal
session.

Updating only the agents can be done with:

```
GOCD_ENVIRONMENT=prod ./tasks tf_plan_agents create
GOCD_ENVIRONMENT=prod ./tasks tf_apply
```

To deploy/re-deploy a specific agent, e.g. for `agent 3`:

```
GOCD_ENVIRONMENT=prod ./tasks tf_plan_agent 3 create
GOCD_ENVIRONMENT=prod ./tasks tf_apply
```

Agent's images are built and pushed manually, `Dockerfile`s are versioned
at [nhsconnect/prm-docker-gocd-agent](https://github.com/nhsconnect/prm-docker-gocd-agent).

#### Deployment From Linux

From Linux (Ubuntu 18.0.4 LTS tested) the network setup is slightly different and SSH forwarding does not work out of
the box,
neither does DNS resolution over VPN. Simplest setup is to use direct networking without the tunnel requiring these
changes (currently requiring manual change, scripts automated for use on MACOS):

- Use `Dojofile-ansible-linux` to fix the DNS
- Instead of `docker.host.internal`, use `<gocd env>.gocd.patient-deductions.nhs.uk`
- Don't use the `-p / -P 2222` switches, go directly to SSH port 22

### Google Chat Notification Set Up

1. `git clone https://github.com/susmithasrimani/gocd-google-chat-build-notifier.git`
2. `cd gocd-google-chat-build-notifier`
3. `./gradlew uberJar`
4. Make sure you can `ssh` into GoCD server
5. `scp build/libs/gocd-google-chat-build-notifier-uber.jar <user>@<gocd-server-ip>:/var/gocd-data/data/plugins/external/`
6. Go back to `prm-gocd-infra`
7. Make sure you've assumed the AWS role with elevated permissions
8. `./tasks provision`
9. Reboot the GoCD server EC2 instance, preferably by restarting Docker instance on the server you `ssh`ed into
10. Go to [GoCD plugins page](https://prod.gocd.patient-deductions.nhs.uk/go/admin/plugins)
11. Click on the cogwheel next to the Google Chat Build Notifier plugin
12. Paste the Google Chat webhook token into `Webhook URL` field. You can find Google Chat webhook token in
    the `NHS - PRM Build Failures` room at `Manage webhooks` option.

### SSL Certificate Update

This uses [certbot](https://certbot.eff.org/) and [letsencrypt](https://letsencrypt.org/) and appears to only generate
on your local machine (using AWS DNS automatically to
prove ownership of domain) and then upload to `/etc/letsencrypt` can occur.

First awsume (or assume-role) the AWS CI user
```bash
awsume ci
```

These steps were done on a machine that recently deployed GOCD agents, so it had `gocd-prod` and `gocd-prod.pub` keys
in `terraform/ssh/`. If you don't have this, you need to run `./tasks ssh_key`.

Then generate and sync the certificates
(If you've not set your `GOCD_ENVIRONMENT` variable, these will need to be prefixed with `GOCD_ENVIRONMENT=prod`)
```bash
./tasks generate_ssl_certs
sudo ./tasks sync_certs
```

Ensure you are connected to the GoCD VPN and then SSH into the EC2
```bash
ssh -i terraform/ssh/gocd-prod ec2-user@prod.gocd.patient-deductions.nhs.uk
```

Over SSH on the GoCD server, you can then issue:
```bash
docker restart nginx
```

## TODO

- SSL certs are currently issued manually from workstation and sent over to the GoCD server. It could be automated on
  the GoCD machine
- Connecting GoCD analytics to RDS requires to plugin settings via the UI
- Agent's auto-registration key was placed in SSM store manually. This is a one-time operation
- Agents could be placed behind a NAT

## Troubleshooting & Common Issues

### GoCD Disk/Memory Related Issues

You can release some disk space by doing the following whilst logged onto the server:

1. Stop the `server` container: `docker stop server`
2. Remove the stopped `server` container to release some disk space: `docker system prune`
3. Start a new `server`
   container: `docker run --detach -p "8153:8153" -p "8154:8154" --env GCHAT_NOTIFIER_CONF_PATH=/home/go/gchat_notif.conf --env GOCD_SERVER_JVM_OPTS="-Dlog4j2.formatMsgNoLookups=true" --volume "/var/gocd-data/data:/godata" --volume "/var/gocd-data/go-working-dir:/go-working-dir" --volume "/var/gocd-data/home:/home/go" --name server gocd-server:latest`