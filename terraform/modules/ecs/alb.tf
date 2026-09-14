resource "aws_lb" "backend" {
	name = "${var.name_prefix}-alb"
	internal = false
	load_balancer_type = "application"
	security_groups = [aws_security_group.alb.id]
	subnets = var.public_subnet_ids 
}

resource "aws_lb_target_group" "backend"{
	name = "${var.name_prefix}-alb-tg"
	port = var.container_port
	target_type = "ip"
	protocol = "HTTP"
	vpc_id = var.vpc_id

	health_check{
		path = "/health"
		healthy_threshold = 2
		unhealthy_threshold = 3
		interval = 30
		timeout = 5
	}
}

resource "aws_lb_listener" "http"{
	load_balancer_arn = aws_lb.backend.arn
	port = 80
	protocol = "HTTP"

	default_action {
		type = "forward"
		target_group_arn = aws_lb_target_group.backend.arn
	}
}
