
module "local-agents" {
    source = "./agent-module"
    root_domain = var.root_domain
    agent_count = 2
    subnet_id = local.subnet_id
    region = var.region
    agent_image_tag = var.agent_image_tag
    environment = var.environment
    allocate_public_ip = true #TODO: use NAT for agents
    gocd_agent_volume_size = var.gocd_agent_volume_size
    agent_flavor = var.agent_flavor
    az = var.az
    agent_sg_id = aws_security_group.go_agent_sg.id
    agent_instance_profile = aws_iam_instance_profile.gocd_agent.name
    agent_keypair_name = aws_key_pair.gocd.key_name
}
