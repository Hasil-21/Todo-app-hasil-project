resource "aws_cloudwatch_log_group" "backend"{
	name = "/ecs/${var.name_prefix}-backend-2"
	retention_in_days = 14
}


