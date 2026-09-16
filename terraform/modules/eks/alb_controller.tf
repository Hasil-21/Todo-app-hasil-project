resource "aws_iam_policy" "alb_controller" {
	name = "${var.name_prefix}-alb-controller-policy"
	policy = file("${path.module}/alb_controller_iam_policy.json")
}

resource "aws_iam_role" "alb_controller" {
	name = "${var.name_prefix}-alb-controller-role"
	
	assume_role_policy = jsonencode ({
		Version = "2012-10-17"
		Statement = [{
			Effect = "Allow"
			Principal = {
				Federated = aws_iam_openid_connect_provider.eks.arn
			}
			Action = "sts:AssumeRoleWithWebIdentity"
			Condition = {
				StringEquals = {
					"${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
					"${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud" = "sts.amazonaws.com"
				}
			}
		}]
	})
}

resource "aws_iam_role_policy_attachment" "alb_controller" {
	role = aws_iam_role.alb_controller.name
	policy_arn = aws_iam_policy.alb_controller.arn
}

resource "kubernetes_service_account" "alb_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.alb_controller.arn
    }
    labels = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/name"      = "aws-load-balancer-controller"
    }
  }

  depends_on = [aws_eks_node_group.this]
}

resource "helm_release" "alb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.8.1"   # chart version matching app v2.13.2 — verify with `helm search repo` if this drifts
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = aws_eks_cluster.this.name
  }
  set {
    name  = "serviceAccount.create"
    value = "false"
  }
  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account.alb_controller.metadata[0].name
  }
  set {
    name  = "region"
    value = data.aws_region.current.name
  }
  set {
    name  = "vpcId"
    value = var.vpc_id
  }

  depends_on = [kubernetes_service_account.alb_controller]
}

data "aws_region" "current" {}
