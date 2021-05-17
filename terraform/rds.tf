resource "aws_kms_key" "gocd_key" {
  description             = "GoCD DB key in prod environment"
  policy = <<EOT
  {
    "Version": "2012-10-17",
    "Id": "key-default-1",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::327778747031:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        }
    ]
}

EOT
  tags                    = {
    CreatedBy   = var.repo_name
    Environment = var.environment
    Name       = "prod-gocd-db"
  }
}


resource "aws_rds_cluster" "db_cluster" {
    cluster_identifier      = "${var.environment}-gocd-db-cluster"
    engine                  = "aurora-postgresql"
    database_name           = "gocddb"
    master_username         = data.aws_ssm_parameter.gocd_db_username.value
    master_password         = data.aws_ssm_parameter.gocd_db_password.value
    backup_retention_period = 5
    preferred_backup_window = "07:00-09:00"
    vpc_security_group_ids  = [aws_security_group.db_sg.id]
    apply_immediately       = true
    db_subnet_group_name    = aws_db_subnet_group.db_cluster_subnet_group.name
    skip_final_snapshot     = true
    storage_encrypted       = true

    tags = {
      CreatedBy   = var.repo_name
      Environment = var.environment
    }
}

resource "aws_ssm_parameter" "rds_endpoint" {
    name = "/repo/${var.environment}/output/${var.repo_name}/gocd-rds-endpoint"
    type = "String"
    value = aws_rds_cluster.db_cluster.endpoint
    tags = {
      CreatedBy   = var.repo_name
      Environment = var.environment
    }
}

resource "aws_db_subnet_group" "db_cluster_subnet_group" {
  name       = "${var.environment}-gocd-db-subnet-group"
  subnet_ids = [aws_subnet.db_subnet_a.id, aws_subnet.db_subnet_b.id]

  tags = {
    Name = "${var.environment}-gocd-db-subnet-group"
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_rds_cluster_instance" "gocd_db_instances" {
  count                 = 1
  identifier            = "${var.environment}-gocd-db-instance-${count.index}"
  cluster_identifier    = aws_rds_cluster.db_cluster.id
  instance_class        = "db.t3.medium"
  engine                = "aurora-postgresql"
  db_subnet_group_name  = aws_db_subnet_group.db_cluster_subnet_group.name
  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}
