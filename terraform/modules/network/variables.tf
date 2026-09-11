variable "name_prefix"{
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

variable "vpc_cidr_block"{
	type = string
	default = "10.0.0.0/16"
}

variable "public_subnet_cidrs"{
	type = list(string)
	default = ["10.0.1.0/24","10.0.2.0/24"]
}


variable "private_subnet_cidrs"{
	type = list(string)
	default = ["10.0.3.0/24","10.0.4.0/24"]
}
