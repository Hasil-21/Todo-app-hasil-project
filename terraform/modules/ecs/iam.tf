data "aws_caller_identity" "current" {}

resource "aws_iam_role" "execution" {
	name = "${var.name_prefix}-ecs-execution-role"

	assume_role_policy = jsonencode({
		Version = "2012-10-17"
		Statement = [{
			Action = "sts:AssumeRole"
			Effect = "Allow" 
			Principal = {
				Service = "ecs-tasks.amazonaws.com"
			}
		}]
	})
}


resource "aws_iam_role_policy_attachment" "execution"{
	role = aws_iam_role.execution.name
	policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


resource "aws_iam_role_policy" "execution_secrets"{
  name = "${var.name_prefix}-execution-secrets"
  role = aws_iam_role.execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue"]
      Resource = var.db_secret_arn
    }]
  })
}

resource "aws_iam_role" "task"{
	name = "${var.name_prefix}-ecs-task-role"
	
	assume_role_policy = jsonencode({
		Version = "2012-10-17"
		Statement = [{
			Effect = "Allow"
			Action = "sts:AssumeRole"
			Principal = { Service = "ecs-tasks.amazonaws.com"}
		}]
	})
}
