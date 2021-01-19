output "server_public_ip" {
  value = aws_instance.gocd_server.public_ip
}

output "environment" {
  value = var.environment
}

output "remote_user" {
  value = local.remote_user
}

output "db_url" {
  value = aws_rds_cluster.db_cluster.endpoint
}

output "db_user" {
  sensitive = true
  value = data.aws_ssm_parameter.gocd_db_username.value
}

output "db_password" {
  sensitive = true
  value = data.aws_ssm_parameter.gocd_db_password.value
}

