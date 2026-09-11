locals {
	env_region_map = {
		"dev"="ap-south-1"
		"prod"="us-east-1"
	}

	region = lookup(local.env_region_map,var.environment,"unknown") 
	name = "${var.name_prefix}-${var.environment}-${local.region}"
}

resource "random_password" "db" {
	length = 20
	special = true
	min_uper = 2
	min_lower = 2
	min_numeric = 2
	override_special = "!#$%^&*()-_=+[]{}<>:?"
}	

resource "aws_secretsmanager_secret" "db"{
	name = "${local.name-db-password}"

	tags = {
		Name = "${local.name}-db-password"
	}	
}

resource "aws_secretsmanager_secret_version" "db"{
	secret_id = aws_secretsmanager_secret.db.id
	secret_string = jsonencode({
		username = var.db_username
		password = random_password.db.result
		dbname = var.db_name
}

resource "aws_db_subnet_group" "this"{
	name = "${local.name}-db-subnet-group"
	subnet_ids = var.private_subnet_ids

	tags = {
		Name = "${local.name}-db-subnet-group"
	}
}

resource "aws_security_group" "db"{
	name = "${local.name}-db-sg"
	description = "Allow postgres access the rds"
	vpc_id = var.vpc_id

	tags = {
		Name = "${local.name}-db-sg"
	}

	ingress {
		count = length(var.allowed_security_group_ids)	
		protocol = "tcp"
		from_port = 5432
		to_port = 5432
		source_security_group_id = var.allowed_security_group_ids[count.index] 
	}

	ingress {

}

resource


resource "aws_db_instance" "this" {
	 allocated_storage    = 20
	 db_name              = "${local.name}-db"
	 engine               = "postgres"
	 engine_version       = "18.3"
	 instance_class       = "db.t3.micro"
	 username             = var.username
	 password             = var.dbpassword
	 skip_final_snapshot  = true
}
