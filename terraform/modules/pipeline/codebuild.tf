resource "aws_codebuild_project" "build"{
	name = "${var.name_prefix}-codebuild"
	service_role = aws_iam_role.codebuild.arn

	artifacts {
		type = "CODEPIPELINE"
	}

	environment {
		compute_type = "BUILD_GENERAL1_SMALL"
		image = "aws/codebuild/amazonlinux2-x86_64-standard:6.0"
		type = "LINUX_CONTAINER"
		privileged_mode = true
	
		environment_variable {
			name = "ECR_REPO_URL"
			value = var.ecr_repository_url
		}
	}

	source{
		type = "CODEPIPELINE"
		buildspec = var.buildspec_path
	}
}


resource "aws_codebuild_project" "build_frontend"{
	name = "${var.name_prefix}-codebuild-frontend"
	service_role = aws_iam_role.codebuild.arn

	artifacts {
		type = "CODEPIPELINE"
	}

	environment {
		compute_type = "BUILD_GENERAL1_SMALL"
		image = "aws/codebuild/amazonlinux2-x86_64-standard:6.0"
		type = "LINUX_CONTAINER"
		privileged_mode = false
		
		environment_variable {
			name = "FE_BUCKET"
			value = var.fe_bucket_name
		}
	
		environment_variable {
			name = "CLOUDFRONT_DISTRIBUTION_ID"
			value = var.cf_distribution_id
		}
	}

	source {
		type = "CODEPIPELINE"
		buildspec = var.fe_buildspec_path
	}
}

resource "aws_codepipeline" "this"{
	name = "${var.name_prefix}-codepipeline"
	role_arn = aws_iam_role.codepipeline.arn

	artifact_store{
		location = aws_s3_bucket.artifacts.bucket
		type = "S3"
	}	

	stage {
		name = "Source"
	
		action {
			name = "Source"
			category = "Source"
			owner = "AWS"
			provider = "CodeStarSourceConnection"
			version = "1"
			output_artifacts = ["source_output"]
	
			configuration = {
				ConnectionArn = aws_codestarconnections_connection.github.arn
				FullRepositoryId = "${var.github_owner}/${var.github_repo}"
				BranchName = var.github_branch
			}
		}
	}


	stage {
		name = "Build-backend"
		
		action {
			name = "Build"
			category = "Build"
			owner = "AWS"
			provider = "CodeBuild"
			version = "1"
			input_artifacts = ["source_output"]
			output_artifacts = ["build_output"]

			configuration = {
				ProjectName = aws_codebuild_project.build.name
			}
		}
	}

	stage {
		name = "Build-frontend"
		
		action {
			name = "Build"
			category = "Build"
			owner = "AWS"
			provider = "CodeBuild"
			version = "1"
			input_artifacts = ["source_output"]
			
			configuration = {
				ProjectName = aws_codebuild_project.build_frontend.name
			}
		}
	}

	
	stage {
		name = "Deploy"

		action {
			name = "Deploy"
			category = "Deploy"
			owner = "AWS"
			provider = "ECS"
			version = "1"
			input_artifacts = ["build_output"]

			configuration = {
				ClusterName = var.ecs_cluster_name
				ServiceName = var.ecs_service_name 
				FileName = "imagedefinitions.json"
			}

		}
	}
}
