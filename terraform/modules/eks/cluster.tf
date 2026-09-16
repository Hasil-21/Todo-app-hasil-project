data "aws_caller_identity" "current" {}

resource "aws_iam_role" "cluster"{
	name = "${var.name_prefix}-eks-cluster-role"

	assume_role_policy = jsonencode ({
		Version = "2012-10-17"
		Statement = [{
			Effect = "Allow"
			Principal = { Service = "eks.amazonaws.com" }
			Action = "sts:AssumeRole"
		}]
	})
}

resoruce "aws_iam_role_policy_attachment" "cluster_policy" {
	role = aws_iam_role.cluster.name
	policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_eks_cluster" "this"{
	name = var.name_prefix
	role_arn = aws_iam_role.cluster.arn
	version = "1.31"

	vpc_config {
		subnet_id = concat(var.pirvate_subnet_ids,var.public_subnet_ids)
		endpoint_private_access = true
		endpoint_public_access = true
	}
	
	depends_on = [aws_iam_role_policy_attachement.cluster_policy]
}
