#resource "kubernetes_secret" "spring-cloud-data-flow-server-env" {
#  metadata {
#    name = "spring-cloud-data-flow-server-env"
#    namespace = kubernetes_namespace.lutergs.metadata[0].name
#  }
#
#  data = {
#    SPRING_DATASOURCE_URL = "jdbc:postgresql://${var.spring-cloud-data-flow-info.database-host}:${var.spring-cloud-data-flow-info.database-port}/dataflow"
#    SPRING_DATASOURCE_USERNAME = "dataflow"
#    SPRING_DATASOURCE_PASSWORD = var.spring-cloud-data-flow-info.dataflow-password
#    SPRING_DATASOURCE_DRIVER_CLASS_NAME = "org.postgresql.Driver"
#  }
#}
#
#resource "kubernetes_secret" "spring-cloud-data-flow-skipper-env" {
#  metadata {
#    name = "spring-cloud-data-flow-skipper-env"
#    namespace = kubernetes_namespace.lutergs.metadata[0].name
#  }
#
#  data = {
#    SPRING_DATASOURCE_URL = "jdbc:postgresql://${var.spring-cloud-data-flow-info.database-host}:${var.spring-cloud-data-flow-info.database-port}/skipper"
#    SPRING_DATASOURCE_USERNAME = "skipper"
#    SPRING_DATASOURCE_PASSWORD = var.spring-cloud-data-flow-info.skipper-password
#    SPRING_DATASOURCE_DRIVER_CLASS_NAME = "org.postgresql.Driver"
#  }
#}
#
#resource "helm_release" "spring-cloud-data-flow" {
#  name = "spring-cloud-data-flow"
#  namespace = kubernetes_namespace.lutergs.metadata[0].name
#  repository = "oci://registry-1.docker.io/bitnamicharts"
#  chart = "spring-cloud-dataflow"
#
#  values = [<<EOF
#server:
#  replicaCount: 2
#  extraEnvVarsSecret: ${kubernetes_secret.spring-cloud-data-flow-server-env.metadata[0].name}
#
#skipper:
#  replicaCount: 2
#  extraEnvVarsSecret: ${kubernetes_secret.spring-cloud-data-flow-skipper-env.metadata[0].name}
#
#mariadb:
#  enabled: false
#
#rabbitmq:
#  enabled: false
#
#kafka:
#  enabled: false
#
#externalKafka:
#  enabled: true
#  brokers: ${confluent_kafka_cluster.default.bootstrap_endpoint}
#
#spring:
#  cloud:
#    deployer:
#      kubernetes:
#        environmentVariables:
#          - spring.cloud.stream.kafka.binder.configuration.security.protocol=SASL_SSL
#          - spring.cloud.stream.kafka.binder.configuration.sasl.jaas.config="org.apache.kafka.common.security.plain.PlainLoginModule required username='${var.spring-cloud-data-flow-info.kafka-cluster-api-key}' password='${var.spring-cloud-data-flow-info.kafka-cluster-api-secret}'";
#          - spring.cloud.stream.kafka.binder.configuration.sasl.mechanism=PLAIN
#          - spring.cloud.stream.kafka.binder.configuration.client.dns.lookup=use_all_dns_ips
#EOF
#  ]
#}