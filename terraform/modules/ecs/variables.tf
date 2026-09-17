variable "name_prefix" {
	type = string
	default = "todo-app"
}

variable "environment"{
	type = string

	validation{
		condition = contains(["dev","prod"],var.environment)
		error_message = "environment must be dev OR prod"
	}
}

variable "vpc_id"{
	type = string
}

variable "private_subnet_ids"{
	type = list(string)
}

variable "public_subnet_ids"{
	type = list(string)
}

variable "container_port"{
	type = number
	default = 5000
}

variable "db_secret_arn" {
  description = "Secrets Manager ARN holding PGUSER/PGPASSWORD"
  type        = string
}

variable "environment_variables" {
  description = "Plain (non-secret) env vars for the container"
  type        = map(string)
}

variable "repository_url"{
	type = string
}
