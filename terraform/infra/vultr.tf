// get existing kubernetes cluster
data "vultr_kubernetes" "vke-cluster" {
  filter {
    name   = "label"
    values = ["default-cluster"]
  }
}

output "k8s-version" {
  value = trimsuffix(data.vultr_kubernetes.vke-cluster.version, "+1")
}