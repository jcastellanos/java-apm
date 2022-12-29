terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

provider "kubernetes" {
  config_path    = "./k3s.yaml"
  config_context = "default"
}

resource "kubernetes_deployment" "go-rest-api" {
  metadata {
    name = "go-rest-api-deployment"
    labels = {
      App = "go-rest-api"
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        App = "go-rest-api"
      }
    }
    template {
      metadata {
        labels = {
          App = "go-rest-api"
        }
      }
      spec {
        container {
          image = "jcastellanos/go-rest-api:latest"
          name  = "go-rest-api-container"

          port {
            container_port = 8080
          }
		  
		  readiness_probe {
			http_get {
			  path = "/calcular?a=1&b=2"
			  port = 8080
			}
			initial_delay_seconds = 30
			timeout_seconds = 3
			period_seconds = 10
			failure_threshold = 3
		  }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "64Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "go-rest-api" {
  metadata {
    name = "go-rest-api-service"
  }
  spec {
    selector = {
      App = kubernetes_deployment.go-rest-api.spec.0.template.0.metadata[0].labels.App
    }
    port {
      node_port   = 31000
      port        = 8080
      target_port = 8080
    }

    type = "NodePort"
  }
}

resource "kubernetes_ingress_v1" "go-rest-api" {
  metadata {
    name = "go-rest-api-ingress"
  }

  spec {
    rule {
	  host = "gorest.192.168.20.60.nip.io"
      http {
        path {
          backend {
			service {
				name = "go-rest-api-service"
				port {
                  number = 8080
                }
			}
          }

          path = "/"
        }
      }
    }
  }
}