terraform{
	required_version = ">= 1.5.0"

	required_providers{
		aws = {
			source = "hashicorp/aws"
			version = "~> 5.0"
		}
	}
}

provider "aws" {
	region = "ap-south-1"
}

module "network"{
	source = "../../modules/network"

	environment = "dev"
	vpc_cidr_block = "10.0.0.0/16"
	public_subnet_cidrs = ["10.0.1.0/24","10.0.2.0/24"]
	private_subnet_cidrs = ["10.0.3.0/24","10.0.4.0/24"]
}

module "rds"{
	source = "../../modules/rds"

	environment = "dev"
	vpc_id = module.network.vpc_id
	db_name = "todoAppDb"
	db_username = "todoAppAdmin" 
	private_subnet_ids = module.network.private_subnet_ids
	allowed_security_group_ids = [module.ecs.ecs_tasks_security_group_id]
	allowed_cidr_blocks = []
}

module "ecs"{
	source = "../../modules/ecs"
	
	environment = "dev"
	vpc_id = module.network.vpc_id
	private_subnet_ids = module.network.private_subnet_ids
	public_subnet_ids = module.network.public_subnet_ids
	db_secret_arn = module.rds.secrets_manager_secret_arn
	environment_variables = {
		PORT = "5000"
		PGDATABASE = "todoAppDb"
		CLIENT_ORIGIN = "https://${module.cloudfront.cloudfront_domain_name}"
		PGHOST = module.rds.db_endpoint
		PGPORT = "5432"
		AWS_REGION = "ap-south-1"
	}
}

module "cloudfront"{
	source = "../../modules/cloudfront"

	environment = "dev"
	domain_name = module.ecs.alb_dns_name
}

