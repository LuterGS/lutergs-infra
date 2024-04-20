resource "kubernetes_namespace" "istio-system" {
  metadata {
    name = "istio-system"
  }
}

resource "kubernetes_namespace" "istio-ingress" {
  metadata {
    name = "istio-ingress"
  }
}


resource "helm_release" "istio-base" {
  name = "istio-base"
  namespace = kubernetes_namespace.istio-system.metadata[0].name
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart = "base"
  set {
    name  = "defaultRevision"
    value = "default"
  }
}


resource "helm_release" "istio-cni" {
  name = "istio-cni"
  namespace = "kube-system"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart = "cni"

  # https://ranchermanager.docs.rancher.com/integrations-in-rancher/istio/configuration-options/install-istio-on-rke2-cluster
  set {
    name  = "cni.cniBinDir"
    value = "/var/lib/rancher/k3s/data/current/bin"
  }
  set {
    name  = "cni.cniConfDir"
    value = "/var/lib/rancher/k3s/agent/etc/cni/net.d"
  }
}

resource "helm_release" "istio-discovery" {
  name = "istio-discovery"
  namespace = kubernetes_namespace.istio-system.metadata[0].name
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart = "istiod"
  values = [<<EOF
meshConfig:
  enableTracing: true
  defaultConfig:
    tracing:
      zipkin:
        address: k8s-monitoring-grafana-agent.telemetry.svc.cluster.local:9411
  extensionProviders:
    - name: zipkin
      zipkin:
        service: k8s-monitoring-grafana-agent.telemetry.svc.cluster.local
        port: 9411

defaults:
  pilot:
    resources:
      requests:
        cpu: 100m
        memory: 500Mi
EOF
]
}

// must be install after istio-discovery is installed
resource "helm_release" "istio-gateway" {
  name = "istio-ingress"
  namespace = kubernetes_namespace.istio-ingress.metadata[0].name
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart = "gateway"
  set {
    name  = "service.loadBalancerIP"
    value = oci_core_instance.k8s-master.public_ip
  }
  values = [<<EOF
service:
  externalIPs:
    - ${oci_core_instance.k8s-master.public_ip}
EOF
]
}

resource "kubernetes_ingress_class_v1" "istio-ingress" {
  metadata {
    name = "istio"
  }
  spec {
    controller = "istio.io/ingress-controller"
  }
}
