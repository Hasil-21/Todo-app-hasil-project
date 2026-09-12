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

module "cloudfront"{
	source = "../../modules/cloudfront"

	environment = "dev"
}

module "rds"{
	source = "../../modules/rds"

	environment = "dev"
	vpc_id = mpdule.network.vpc_id
	db_name = "todo-app-db"
	db_username = "todo-app-admin" 
	private_subnet_ids = module.network.private_subnet_ids
	allowed_security_group_ids = []
	allowed_cidr_blocks = ["0.0.0.0/0"]
}
