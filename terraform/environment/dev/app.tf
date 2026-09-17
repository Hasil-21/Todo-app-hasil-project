resource "kubernetes_namespace" "todo_app" {
	metadata {
		name = "todo-app"
	}
	depends_on = [module.eks]
}


resource "kubernetes_config_map" "todo_app"{
	metadata {
		name = "todo-app-config"
		namespace = kubernetes_namespace.todo_app.metadata[0].name
	}

	data = {
		PORT = "5000"
		PGHOST = module.rds.db_endpoint
		PGDATABASE = "todoAppDb" 
		PGPORT = "5432"
		CLIENT_ORIGIN = "https://${module.cloudfront.cloudfront_domain_name}"
		AWS_REGION = "ap-south-1"
	}
}

data "aws_secretsmanager_secret_version" "db"{
	secret_id = "todo-app-dev-ap-south-1-db-password-6"

	depends_on = [module.rds.secrets_manager_secret_arn]
}

resource "kubernetes_secret" "todo_app_db"{
	metadata {
		name = "todo-app-db-secret"
		namespace = kubernetes_namespace.todo_app.metadata[0].name
	}

	data = {
		PGUSER = jsondecode(data.aws_secretsmanager_secret_version.db.secret_string)["username"]
		PGPASSWORD = jsondecode(data.aws_secretsmanager_secret_version.db.secret_string)["password"]
	}
}

resource "kubernetes_deployment" "todo_app_backend" {
	metadata {
		name = "todo-app-deployment"
		namespace = kubernetes_namespace.todo_app.metadata[0].name
	}

	spec {
		replicas = 1

		template {
			metadata {
				labels = {
					app = "todo-app-backend"
				}
			}

			spec {
				container {
					name = "backend"
					image = "${module.ecr.ecr_repository_url}:latest"

					port { container_port = 5000 }
					
					env_from {
						config_map_ref {
							name = kubernetes_config_map.todo_app.metadata[0].name
						}
					}

					env_from {
						secret_ref {
							name = kubernetes_secret.todo_app_db.metadata[0].name
						}
					}

					liveness_probe {
						http_get {
							path = "/health"
							port = 5000
						}
						initial_delay_seconds = 10
						period_seconds = 15
					}
	
					readiness_probe {
						http_get {
							path = "/health"
							port = 5000
						}
						initial_delay_seconds = 5
						period_seconds = 10
					}

					resources {
						requests = {
							cpu = "250m"
							memory = "256Mi"
						}
						limits = {
							cpu = "512m"
							memory = "512Mi"
						}
					}
				}
			}
		}

		selector {
			match_labels = {
				app = "todo-app-backend"
			}	
		}
	}

depends_on = [
	kubernetes_config_map.todo_app,
	kubernetes_secret.todo_app_db,
	module.eks.alb_controller_helm_release
]
}


resource "kubernetes_service" "todo_app_backend" {
	metadata {
		name = "todo-app-backend-svc"
		namespace = kubernetes_namespace.todo_app.metadata[0].name
	}

	spec {
		selector = {
			app = "todo-app-backend"
		}
	
		port {
			port = 80
			target_port = 5000
		}
		
		type = "ClusterIP"
	}
}


resource "kubernetes_ingress_v1" "todo_app_backend" {
	metadata {
		name = "todo-app-ingress"
		namespace = kubernetes_namespace.todo_app.metadata[0].name
	
		annotations = {
			"kubernetes.io/ingress.class" = "alb"
			"alb.ingress.kubernetes.io/scheme" = "internet-facing"
			"alb.ingress.kubernetes.io/target-type" = "ip"
			"alb.ingress.kubernetes.io/healthcheck-path" = "/health"
			"alb.ingress.kubernetes.io/listen-ports" = jsonencode([{ HTTP = 80 }])
		}
	}

	spec {
		rule {
			http {
				path {
					path = "/"
					path_type = "Prefix"
				
					backend {
						service {
							name = kubernetes_service.todo_app_backend.metadata[0].name
							port {
								number = 80
							}
						}
					}
				}
			}
		}
	}
	
	depends_on = [module.eks.alb_controller_helm_release]
}

