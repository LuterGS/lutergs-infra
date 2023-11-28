resource "confluent_environment" "default" {
  display_name = "default"

  lifecycle {
    prevent_destroy = true
  }
}

resource "confluent_kafka_cluster" "default" {
  display_name = "lutergs-default-cluster"
  availability = "SINGLE_ZONE"
  cloud = "AWS"
  region = "ap-northeast-2"
  basic {}

  environment {
    id = confluent_environment.default.id
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "confluent_service_account" "default" {
  display_name = "opentofu-client"
  description = "Service Account for OpenTofu"
}

resource "confluent_api_key" "default" {
  display_name = "opentofu-api-key"
  description = "OpenTofu managed Kafka cluster access key"
  owner {
    api_version = confluent_service_account.default.api_version
    id          = confluent_service_account.default.id
    kind        = confluent_service_account.default.kind
  }
  managed_resource {
    api_version = confluent_kafka_cluster.default.api_version
    id          = confluent_kafka_cluster.default.id
    kind        = confluent_kafka_cluster.default.kind

    environment {
      id = confluent_environment.default.id
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}