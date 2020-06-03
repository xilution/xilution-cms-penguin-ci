resource "gitlab_project_hook" "xilution-pipeline-hook" {
  project = "${var.gitlab_project}/${var.gitlab_repository}"
  url = "https://webhooks.xilution.com/gitlab/repository/push"
  push_events = true
  token = var.penguin_pipeline_id
}
