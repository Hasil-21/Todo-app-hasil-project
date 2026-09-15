variable "name_prefix"{
	type = string
	default = "todo-app"
}


variable "environment" {
	type = string

	validation {
		condition = contains(["dev","prod"],var.environment)
		error_message = "environment must be dev OR prod"
	}
}

variable "ecr_repository_url"{
	type = string
}

variable "github_branch"{
	type = string
	default = "main"
}

variable "github_owner"{
	type = string
	default = "Hasil-21"
}

variable "github_repo"{
	type = string
	default = "Todo-app-hasil-project"
}

variable "ecs_cluster_name"{
	type = string
}

variable "ecs_service_name"{
	type = string
}

variable "buildspec_path"{
	type = string
	default = "todo-app/backend/buildspec.yml"
}

variable "fe_bucket_name"{
	type = string
}

variable "cf_distribution_id"{
	type = string
}

variable "fe_buildspec_path"{
	type = string
	default = "todo-app/frontend/buildspec.yml"
}
