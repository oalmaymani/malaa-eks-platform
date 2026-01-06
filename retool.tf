resource "kubernetes_namespace" "retool" {
  metadata {
    name = "retool"
  }
}

resource "helm_release" "retool" {
  name       = "retool"
  repository = "https://charts.retool.com"
  chart      = "retool"
  namespace  = kubernetes_namespace.retool.metadata[0].name

  values = [
    yamlencode({
      image = {
        tag = "3.75.17-stable"
      }

      postgresql = {
        enabled = true
        auth = {
          password = "retool"
        }
        primary = {
          persistence = {
            enabled      = true
            size         = "8Gi"
            storageClass = "gp2"
            mountPath    = "/data"
            dataSubPath  = "pgdata"
          }
          volumePermissions = {
            enabled = true
          }
          podSecurityContext = {
            fsGroup = 1001
          }
          containerSecurityContext = {
            runAsUser = 1001
          }
          extraEnvVars = [
            {
              name  = "PGDATA"
              value = "/data/pgdata"
            }
          ]
        }
      }

      config = {
        encryptionKey = "random-encryption-key-12345"
        licenseKey    = "RETOOL-TRIAL-LICENSE"
      }

      # ✅ main retool resources (some charts use this as default for components)
      resources = {
        requests = {
          cpu    = "100m"
          memory = "256Mi"
        }
        limits = {
          cpu    = "500m"
          memory = "512Mi"
        }
      }

      # ✅ API - Reduce replicas and memory
      replicaCount = 1
      api = {
        replicaCount = 1
        resources = {
          requests = {
            cpu    = "200m"
            memory = "512Mi"
          }
          limits = {
            cpu    = "1000m"
            memory = "1280Mi"
          }
        }
        # ✅ Add Env vars to control memory usage (Reduced to allow overhead)
        env = {
          NODE_OPTIONS = "--max-old-space-size=600"
          JAVA_OPTS    = "-Xmx256m"
        }
      }

      # ✅ FIX: Explicitly enable jobsRunner
      jobRunner = {
        enabled = true
        replicaCount = 1
        resources = {
          requests = {
            cpu    = "100m"
            memory = "256Mi"
          }
          limits = {
            memory = "768Mi"
          }
        }
        env = {
          NODE_OPTIONS = "--max-old-space-size=300"
          JAVA_OPTS    = "-Xmx180m"
        }
      }

      # ✅ disable workflows completely
      workflows = {
        enabled = false
      }

      ingress = {
        enabled = false
      }
    })
  ]

  timeout = 1200
}

resource "kubernetes_ingress_v1" "retool_ingress" {
  metadata {
    name      = "retool-ingress"
    namespace = kubernetes_namespace.retool.metadata[0].name
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
    }
  }

  spec {
    ingress_class_name = "nginx"
    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "retool"
              port {
                number = 3000
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.retool]
}
