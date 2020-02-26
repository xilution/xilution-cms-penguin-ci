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
  description = "The Pipeline ID"
}
