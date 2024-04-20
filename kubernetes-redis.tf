resource "kubernetes_namespace" "redis" {
  metadata {
    name = "redis"
  }
}


resource "helm_release" "redis-sentinel" {
  name = "redis-sentinel"
  namespace = kubernetes_namespace.redis.metadata[0].name
  repository = "oci://registry-1.docker.io/bitnamicharts"
  chart = "redis"

  # https://github.com/bitnami/charts/tree/main/bitnami/redis
  values = [<<EOF
architecture: replication
auth:
  enabled: false
  sentinel: false

master:
  resources:
    requests:
      cpu: 100m
      memory: 256Mi
      ephemeral-storage: 50Mi
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: kubernetes.io/hostname
            operator: NotIn
            values:
            - k8s-master

replica:
  resources:
    requests:
      cpu: 100m
      memory: 256Mi
      ephemeral-storage: 50Mi
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: kubernetes.io/hostname
            operator: NotIn
            values:
            - k8s-master

sentinel:
  enabled: true
  masterSet: lutergs

metrics:
  enabled: true

EOF
]
}