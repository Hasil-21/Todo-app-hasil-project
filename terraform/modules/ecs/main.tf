resource "aws_ecs_cluster" "backend"{
	name = "${var.name_prefix}-cluster"
}

resource "aws_ecs_task_definition" "backend"{
	family = "${var.name_prefix}-backend"
	requires_compatibilities = ["FARGATE"]
	network_mode = "awsvpc"
	memory = 512
	cpu = 256
	execution_role_arn = aws_iam_role.execution.arn
	task_role_arn = aws_iam_role.task.arn

	container_definitions = jsonencode ([{
		name = "backend"
		image = "${aws_ecr_repository.backend.repository_url}:latest"
		essential = true

		portMappings = [{
			containerPort = var.container_port
			protocol = "tcp"
		}]
	
		logConfiguration = {
			logDriver = "awslogs"
			options = {
				"awslogs-group"         = aws_cloudwatch_log_group.backend.name 
				"awslogs-region"        = data.aws_region.current.name
				"awslogs-stream-prefix" = "backend"
			}
		}
		
		environment = [
			for k,v in var.environment_variables : {name = k, value = v}
		]

		secrets = [
			{name = "PGUSER", valueFrom = "${var.db_secret_arn}:username::"},
			{name = "PGPASSWORD", valueFrom = "${var.db_secret_arn}:password::"}
		]
	}])
}

data "aws_region" "current" {}

resource "aws_ecs_service" "backend"{
	name = "${var.name_prefix}-backend-service"
	cluster = aws_ecs_cluster.backend.id
	task_definition = aws_ecs_task_definition.backend.arn 
	desired_count = 1
	launch_type = "FARGATE"

	enable_execute_command = true

	network_configuration{
		subnets = var.private_subnet_ids
		security_groups = [aws_security_group.ecs.id]
		assign_public_ip = false
	}

	load_balancer {
		target_group_arn = aws_lb_target_group.backend.arn
		container_name = "backend"
		container_port = var.container_port
	}	

	depends_on = [aws_lb_listener.http]
}
