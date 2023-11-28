variable "aws-info" {
  type = object({
    access-key = string
    secret-key = string
    region = string
    ecr-key = string
  })
  sensitive = true
}

variable "github-info" {
  type = object({
    access-token = string
    owner = string
  })
  sensitive = true
}

variable "cloudflare-info" {
  type = object({
    email = string
    global-api-key = string
  })
  sensitive = true
}

variable "oci-info" {
  type = object({
    tenancy-ocid = string
    user-ocid = string
    private-key = string
    fingerprint = string
    region = string
  })
  sensitive = true
}

variable "oci-else" {
  type = object({
    oracle-instance-ssh-authorized-keys = object({
      k8s-master = string
      k8s-worker-1 = string
      k8s-worker-2 = string
      k8s-worker-3 = string
    })
  })
  sensitive = true
}

variable "docker-registry-info" {
  type = object({
    username = string
    token = string
  })
  sensitive = true
}

variable "kubernetes-info" {
  type = object({
    host = string
    client-certificate = string
    client-key = string
    cluster-ca-certificate = string
  })
  sensitive = true
}

variable "confluent-cloud-info" {
  type = object({
    cloud_api_key = string
    cloud_api_secret = string
  })
  sensitive = true
}

variable "grafana-cloud-info" {
  type= object({
    cloud-api-token = string
  })
}

variable "spring-cloud-data-flow-info" {
  type = object({
    database-host = string
    database-port = string
    dataflow-password = string
    skipper-password = string
    kafka-cluster-api-key = string
    kafka-cluster-api-secret = string
  })
  sensitive = true
}

// module variables
variable "lutergs-backend-kubernetes-secret"        { type = map(any) }
variable "lutergs-backend-batch-kubernetes-secret"  { type = map(any) }
variable "lutergs-frontend-kubernetes-secret"       { type = map(any) }
variable "lutergs-frontend-pwa-kubernetes-secret"   { type = map(any) }
variable "lutergs-frontend-pwa-public"              { type = map(any)}


