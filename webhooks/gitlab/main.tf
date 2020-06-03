provider "gitlab" {
  token = "${var.gitlab_token}"
}

# Add a hook to the project
resource "gitlab_project_hook" "sample_project_hook" {
  project = "${gitlab_project.sample_project.id}"
  url = "https://example.com/project_hook"
}
