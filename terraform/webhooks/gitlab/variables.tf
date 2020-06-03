variable "penguin_pipeline_id" {
  type = string
  description = "The Penguin Pipeline ID"
}

variable "gitlab_token" {
  type = string
  description = "The Gitlab token assigned to the Xilution user"
}

variable "gitlab_project" {
  type = string
  description = "The Gitlab project to register the webhook with"
}

variable "gitlab_repository" {
  type = string,
  description = "The Gitlab repository to register the webhook with"
}
