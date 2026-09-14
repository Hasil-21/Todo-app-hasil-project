resource "aws_security_group" "alb"{
	name = "${var.name_prefix}-alb"
	vpc_id = var.vpc_id

	ingress{
		protocol = "tcp"
		to_port = 80
		from_port = 80
		cidr_blocks = ["0.0.0.0/0"]
		description = "HTTP from internet"
	}

	egress{
		protocol = "-1"
		to_port = 0
		from_port = 0
		cidr_blocks = ["0.0.0.0/0"]	
	}

	lifecycle { create_before_destroy = true }
}

resource "aws_security_group" "ecs"{
	name = "${var.name_prefix}-ecs"
	vpc_id = var.vpc_id

	ingress{
		protocol = "tcp"
		to_port = var.container_port
		from_port = var.container_port
		description = "From ALB only"
		security_groups = [aws_security_group.alb.id]  
	}

	egress{
		protocol = "-1"
		to_port = 0
		from_port = 0
		cidr_blocks = ["0.0.0.0/0"]
	}
	
	lifecycle { create_before_destroy = true }
}
