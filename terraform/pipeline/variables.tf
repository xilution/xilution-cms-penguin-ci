variable "profile" {
  type = string
  description = "The AWS profile"
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

variable "instance_id" {
  type = string
  description = "The Xilution product instance ID"
}
