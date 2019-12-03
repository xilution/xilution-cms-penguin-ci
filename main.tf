module "managed_wordpress" {
  source = "github.com/xilution/xilution-aws-managed-wordpress-terraform"
  organization_id = var.organization_id
  master_password = var.master_password
  master_username = var.master_username
}
