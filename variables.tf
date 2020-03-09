variable "organization_id" {
  type = string
  description = "The Xilution Account Organization ID or Xilution Account Sub-Organization ID"
}

variable "product_id" {
  type = string
  description = "The Product ID"
  default = "12ea46e5dbb44f87b18b20f801678aa4"
}

variable "pipeline_id" {
  type = string
  description = "The Penguin Pipeline ID"
}

variable "giraffe_pipeline_id" {
  type = string
  description = "The Giraffe Pipeline ID"
}

variable "client_aws_account" {
  type = string
  description = "The Xilution Client AWS Account ID"
}

variable "k8s_cluster_name" {
  type = string
  description = "The Kubernetes Cluster Name"
}

variable "master_username" {
  type = string
  description = "The Database Username"
}

variable "master_password" {
  type = string
  description = "The Database Password"
}
