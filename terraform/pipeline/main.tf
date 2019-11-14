resource "aws_codepipeline" "pipeline" {
  name = "xilution_pipeline_${var.instance_id}"
  role_arn = ""
  artifact_store {
    location = ""
    type = ""
  }
  stage {
    name = ""
    action {
      category = ""
      name = ""
      owner = ""
      provider = ""
      version = ""
    }
  }
  tags = {
    xilution_organization_id = var.organization_id
  }
}
