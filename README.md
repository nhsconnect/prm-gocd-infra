# prm-gocd-infra

Setup of GoCD deployment for NHS deductions team.

Server dashboard is accessible at `https://prod.gocd.patient-deductions.nhs.uk` . The client IPs are whitelisted and you need to authenticate using Github OAuth.

# Architecture

GoCD consists of server and agents.

The server is behind a proxy facing the internet.

There are several agents running in a dedicated VPC. These are general-purpose agents to be used for building code or docker images.

Other agents can be deployed in specific networks. The `remote-agents-module` terraform module can be used to provision agents in other subnets.

## Tools on agents

Each agent has Docker and Dojo available, which makes it possible to build any project as long as you produce a docker image with required tools first. For more details see the [Dojo readme](https://github.com/kudulab/dojo).

# Deployment/Lifecycle

## Prerequisites

- Add your IP address to SSM `inbound ips` parameter.
- Run all the deployment steps we see below from the same machine in order to avoid issue with ssh keys.
- Make sure your AWS profile matches the profile in `provider.tf`.
- Make sure you always run `tf_plan` before running `tf_apply`.

## Deployment

You can pick which deployment to manage by setting environment variable `NHS_ENVIRONMENT`.
To make changes in production, set
```
export NHS_ENVIRONMENT=prod
```

To make changes in this deployment, run:
```
./tasks tf_plan create
```
Review the terraform plan and apply with:
```
./tasks tf_apply
```

At this point EC2 instance should exist. Next step is to install GOCD software on it.
To provision GOCD server use `./tasks provision`.

Updating only the agents can be done with:
```
NHS_ENVIRONMENT=prod ./tasks tf_plan_agents create
NHS_ENVIRONMENT=prod ./tasks tf_apply
```

Agent's images are built and pushed manually, dockerfiles are versioned at [nhsconnect/prm-docker-gocd-agent](https://github.com/nhsconnect/prm-docker-gocd-agent).

# TODO

Some more automation to do:
 - agent's public IPs were whitelisted manually so that they could reach LBs of some of our services. We might want to have internal LBs anyway.
 - SSL certs are currently issued manually from workstation and sent over to the GoCD server. It could be automated on the GoCD machine.
 - Agent's auto-registration key was placed in SSM store manually. This is a one-time operation.

`Dojofile-ansible` uses a public open-source image. It should be forked and managed by deductions team.

Agents could be placed behind a NAT.
