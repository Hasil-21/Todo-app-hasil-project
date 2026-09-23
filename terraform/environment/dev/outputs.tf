#output "eks_alb_hostname" {
#	value = try(kubernetes_ingress_v1.todo_app_backend.status[0].load_balancer[0].ingress[0].hostname, "not yet provisioned")
#}
