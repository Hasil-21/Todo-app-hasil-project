output "db_endpoint"{
	value = aws_db_insatnce.this.endpoint
}

output "db_port"{
	value = aws_db_instance.this.port
}

output "db_name"{
	value = aws_db_insatnce.this.db_name
}

output "db_password"{
	value = random_password.db.result
}

output "db_security_group"{
	value = aws_security_group.db.id
}

output "secrets_manager_secret_arn"{
	value = aws_secretsmanager_secret.db.arn
}
