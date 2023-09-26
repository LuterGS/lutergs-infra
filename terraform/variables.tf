// aws variables
variable "aws-access-key"     { type = string }
variable "aws-secret-key"     { type = string }
variable "aws-region"         { type = string }
variable "aws-ecr-key"        { type = map(string) }

// github variables
variable "github-access-token" { type = string }

// vultr variables
variable "vultr-apk-token" { type = string }

// module variables
variable "lutergs-backend-kubernetes-secret"        { type = map(any) }
variable "lutergs-backend-batch-kubernetes-secret"  { type = map(string) }
