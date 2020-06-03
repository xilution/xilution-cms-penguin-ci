provider "gitlab" {
  token = "${var.gitlab_token}" // auth token
}

resource "gitlab_project_hook" "xilution-pipeline-hook" {
  project = "gitlab_project/gitlab_repo" // "spenserca/spenser-wordpress-docker"
  url = "https://webhooks.xilution.com/gitlab/repository/push"
  push_events = true
  token = "penguin-pipeline-id" // X-Gitlab-Token header value
}
