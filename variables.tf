variable "profile" {
  type = string
  description = "The AWS Profile"
  default = "xilution-prod"
}

variable "region" {
  type = string
  description = "The AWS Region"
  default = "us-east-1"
}

variable "k8s_cluster_name" {
  type = string
  description = "The Kubernetes Cluster Name"
  default = "xilution-k8s"
}

variable "organization_id" {
  type = string
  description = "The Xilution Account Organization ID or Xilution Account Sub-Organization ID"
}

variable "network_stack_name" {
  type = string
  description = "Xilution Network Stack Name"
  default = "xilution-aws-network"
}

variable "master_username" {
  type = string
  description = "The Database Username"
  default = "wordpress"
}

variable "master_password" {
  type = string
  description = "The Database Password"
  default = "wordpress"
}
