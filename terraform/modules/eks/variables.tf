variable "name_prefix"{
	type = string
	default = "todo-app"
}

variable "environment"{
	type = string
	
	validation {
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


