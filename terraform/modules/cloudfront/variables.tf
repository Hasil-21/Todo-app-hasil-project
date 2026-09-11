variable "name_prefix" {
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


