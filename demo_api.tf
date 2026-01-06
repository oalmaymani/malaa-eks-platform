resource "kubernetes_namespace" "demo_api" {
  metadata {
    name = "demo-api"
  }
}

resource "kubernetes_deployment" "demo_api" {
  metadata {
    name      = "hello-world-api"
    namespace = kubernetes_namespace.demo_api.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "hello-world-api"
      }
    }

    template {
      metadata {
        labels = {
          app = "hello-world-api"
        }
      }

      spec {
        container {
          image = "vad1mo/hello-world-rest"
          name  = "hello-world"

          port {
            container_port = 80
          }

          resources {
            requests = {
              cpu    = "10m"
              memory = "64Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "demo_api" {
  metadata {
    name      = "hello-world-service"
    namespace = kubernetes_namespace.demo_api.metadata[0].name
  }

  spec {
    selector = {
      app = "hello-world-api"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_ingress_v1" "api_ingress" {
  metadata {
    name      = "api-ingress"
    namespace = kubernetes_namespace.demo_api.metadata[0].name
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
    }
  }

  spec {
    ingress_class_name = "nginx"
    rule {
      host = "hello-world-malaa.com"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "hello-world-service"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
