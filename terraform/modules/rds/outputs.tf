output "db_endpoint"{
	value = aws_db_instance.this.address
}

output "db_port"{
	value = aws_db_instance.this.port
}

output "db_name"{
	value = aws_db_instance.this.db_name
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

output "secret_id"{
	value = aws_secretsmanager_secret.db.id
}
