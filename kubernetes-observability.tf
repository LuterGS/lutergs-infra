resource "kubernetes_manifest" "istio-telemetry" {
  manifest = {
    apiVersion = "telemetry.istio.io/v1alpha1"
    kind       = "Telemetry"
    metadata   = {
      name      = "trace-default"
      namespace = kubernetes_namespace.istio-system.metadata[0].name
    }
    spec = {
      tracing = [{
        providers = [{
          name = "zipkin"
        }]
        randomSamplingPercentage = 10.00
      }]
    }
  }
}

resource "kubernetes_namespace" "telemetry" {
  metadata {
    name = "telemetry"
  }
}


resource "helm_release" "grafana-cloud-kubernetes-monitoring" {
  name = "k8s-monitoring"
  namespace = kubernetes_namespace.telemetry.metadata[0].name
  repository = "https://grafana.github.io/helm-charts"
  chart = "k8s-monitoring"
  atomic = true
  values = [<<EOF
cluster:
  name: lutergs-cluster
externalServices:
  prometheus:
    host: ${var.grafana-cloud-info.prometheus_endpoint}
    basicAuth:
      username: "${var.grafana-cloud-info.prometheus_username}"
      password: ${var.grafana-cloud-info.api_token}
  loki:
    host: ${var.grafana-cloud-info.loki_endpoint}
    basicAuth:
      username: "${var.grafana-cloud-info.loki_username}"
      password: ${var.grafana-cloud-info.api_token}
  tempo:
    host: ${var.grafana-cloud-info.tempo_endpoint}
    basicAuth:
      username: "${var.grafana-cloud-info.tempo_username}"
      password: ${var.grafana-cloud-info.api_token}
opencost:
  opencost:
    exporter:
      defaultClusterId: lutergs-cluster
    prometheus:
      external:
        url: ${var.grafana-cloud-info.prometheus_endpoint}/api/prom
traces:
  enabled: true
grafana-agent:
  agent:
    extraPorts:
      - name: otlp-grpc
        port: 4317
        targetPort: 4317
        protocol: TCP
      - name: otlp-http
        port: 4318
        targetPort: 4318
        protocol: TCP
      - name: zipkin
        port: 9411
        targetPort: 9411
        protocol: TCP
EOF
]
}