provider "gitlab" {
  token = var.gitlab_token
  // auth token -- this may need to be provided from the org spinning up the stack,
  // or maybe it's just the token assigned to our user that they will allow to their
  // project
}
