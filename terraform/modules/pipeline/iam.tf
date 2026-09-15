data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_iam_role" "codebuild"{
	name = "${var.name_prefix}-codebuild-role"
	
	assume_role_policy = jsonencode({
		Version = "2012-10-17"
		Statement = [{
			Effect = "Allow"
			Action = "sts:AssumeRole"
			Principal = { 
				Service = "codebuild.amazonaws.com" 
			}
		}]
	})
}

resource "aws_iam_role_policy" "codebuild_policy"{
	name = "${var.name_prefix}-codebuild-policy"
	role = aws_iam_role.codebuild.id

	policy = jsonencode({
		Version = "2012-10-17"
		Statement = [{
			Effect = "Allow"
			Action = [
				"logs:CreateLogGroup",
				"logs:CreateLogStream",
				"logs:PutLogEvents"
			]
			Resource = "*"		
		},
		{
			Sid = "EcrAuth"
			Effect = "Allow"
			Action = [
				"ecr:GetAuthorizationToken"
			]
			Resource = "*"
		},
		{
			Sid    = "EcrPush"
			Effect = "Allow"
			Action = [
				"ecr:BatchCheckLayerAvailability",
				"ecr:GetDownloadUrlForLayer",
				"ecr:BatchGetImage",
				"ecr:PutImage",
				"ecr:InitiateLayerUpload",
				"ecr:UploadLayerPart",
				"ecr:CompleteLayerUpload"
			]
			Resource = "*"
		},
		{
			Sid    = "ArtifactBucket"
			Effect = "Allow"
			Action = [
				"s3:GetObject",
				"s3:GetObjectVersion",
				"s3:PutObject"
			]
			Resource = "${aws_s3_bucket.artifacts.arn}/*"
		},
		{
			Sid    = "FrontendBucketSync"
			Effect = "Allow"
			Action = [
				"s3:ListBucket"
			]
			Resource = "arn:aws:s3:::${var.fe_bucket_name}"
		},
		{
			Sid    = "FrontendBucketObjects"
			Effect = "Allow"
			Action = [
				"s3:GetObject",
				"s3:PutObject",
				"s3:DeleteObject"
			]
			Resource = "arn:aws:s3:::${var.fe_bucket_name}/*"
		},
		{
			Sid    = "CloudFrontInvalidation"
			Effect = "Allow"
			Action = [
				"cloudfront:CreateInvalidation"
			]
			Resource = "*"   # CloudFront invalidation doesn't support resource-level ARN scoping on this action
		}]
	})
}

resource "aws_iam_role" "codepipeline"{
	name = "${var.name_prefix}-codepipeline-role"
	
	assume_role_policy = jsonencode({
		Version = "2012-10-17"
		Statement = [{
			Effect = "Allow"
			Action = "sts:AssumeRole"
			Principal = { Service = "codepipeline.amazonaws.com" }
		}]
	})
}

resource "aws_iam_role_policy" "codepipeline"{
	name = "${var.name_prefix}-codepipeline-policy"
	role = aws_iam_role.codepipeline.id

	policy = jsonencode({
		Version = "2012-10-17"
		Statement = [
		{
		 Sid    = "ArtifactBucket"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:GetBucketVersioning"
        ]
        Resource = [
          aws_s3_bucket.artifacts.arn,
          "${aws_s3_bucket.artifacts.arn}/*"
        ]
      },
      {
        Sid      = "GitHubConnection"
        Effect   = "Allow"
        Action   = ["codestar-connections:UseConnection"]
        Resource = aws_codestarconnections_connection.github.arn
      },
      {
        Sid      = "TriggerCodeBuild"
        Effect   = "Allow"
        Action   = ["codebuild:BatchGetBuilds", "codebuild:StartBuild"]
        Resource = aws_codebuild_project.build.arn
      },
      {
        Sid      = "TriggerFrontendCodeBuild"
        Effect   = "Allow"
        Action   = ["codebuild:BatchGetBuilds", "codebuild:StartBuild"]
        Resource = aws_codebuild_project.build_frontend.arn
      },
      {
        Sid    = "DeployToEcs"
        Effect = "Allow"
        Action = [
          "ecs:DescribeServices",
          "ecs:DescribeTaskDefinition",
          "ecs:DescribeTasks",
          "ecs:ListTasks",
          "ecs:RegisterTaskDefinition",
          "ecs:UpdateService"
        ]
        Resource = "*"
      },
      {
        Sid      = "PassEcsRoles"
        Effect   = "Allow"
        Action   = ["iam:PassRole"]
        Resource = "*"
        Condition = {
          StringEqualsIfExists = {
            "iam:PassedToService" = "ecs-tasks.amazonaws.com"
          }
        }
      }
    ]				
	})
}
