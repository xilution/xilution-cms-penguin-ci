module "managed_wordpress" {
  source = "github.com/xilution/xilution-aws-managed-wordpress-terraform"
  organization_id = var.organization_id
}
