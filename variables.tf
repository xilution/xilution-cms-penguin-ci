variable "network_stack_name" {
  type = string
  description = "Xilution Network Stack Name"
  default = "xilution-aws-network"
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

variable "master_username" {
  type = string
  description = "The Database Username"
}

variable "master_password" {
  type = string
  description = "The Database Password"
}

variable "client_aws_account" {
  type = string
  description = "The Xilution Client AWS Account ID"
}
