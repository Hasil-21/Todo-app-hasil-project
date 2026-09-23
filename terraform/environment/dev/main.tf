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


module "ecr" {
	source = "../../modules/ecr"
}

module "ecs"{
	source = "../../modules/ecs"
	
	environment = "dev"
	vpc_id = module.network.vpc_id
	private_subnet_ids = module.network.private_subnet_ids
	public_subnet_ids = module.network.public_subnet_ids
	db_secret_arn = module.rds.secrets_manager_secret_arn
	repository_url = module.ecr.ecr_repository_url
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
#	domain_name = try(kubernetes_ingress_v1.todo_app_backend.status[0].load_balancer[0].ingress[0].hostname,"")
}

#module "pipeline"{
#	source = "../../modules/pipeline"
#	
#	environment = "dev"
#	ecr_repository_url = module.ecr.ecr_repository_url 
#	ecs_service_name = module.ecs.service_name
#	ecs_cluster_name = module.ecs.cluster_name
#	
#	fe_bucket_name = module.cloudfront.bucket_name
#	cf_distribution_id = module.cloudfront.cloudfront_distribution_id	
#	vite_api_url = "http://${module.ecs.alb_dns_name}/api"
#} 

#module "eks"{
#	source = "../../modules/eks"
#	
#	environment = "dev"
#	vpc_id = module.network.vpc_id
#	public_subnet_ids = module.network.public_subnet_ids
#	private_subnet_ids = module.network.private_subnet_ids
#}
