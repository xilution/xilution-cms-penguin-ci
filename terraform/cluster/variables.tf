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

variable "organization_id" {
  type = string
  description = "The Xilution Account Organization ID or Xilution Account Sub-Organization ID"
}

variable "network_stack_name" {
  type = string
  description = "Xilution Network Stack Name"
  default = "xilution-aws-network"
}

variable "cluster_role" {
  type = string
  description = "The Cluster Role"
  default = "xilution-lambda-execution-role"
}
