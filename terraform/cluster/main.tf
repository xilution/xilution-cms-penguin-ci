data "aws_caller_identity" "current" {}

data "aws_cloudformation_export" "vpc_id" {
  name = "${var.network_stack_name}-vpc"
}

data "aws_cloudformation_export" "public_subnet_1_id" {
  name = "${var.network_stack_name}-public-subnet"
}

data "aws_cloudformation_export" "public_subnet_2_id" {
  name = "${var.network_stack_name}-public-subnet-2"
}

resource "aws_efs_file_system" "nfs" {
  tags = {
    xilution_organization_id = var.organization_id
  }
}

resource "aws_efs_mount_target" "mount-target-1" {
  file_system_id = aws_efs_file_system.nfs.id
  subnet_id = data.aws_cloudformation_export.public_subnet_1_id.value
}

resource "aws_efs_mount_target" "mount-target-2" {
  file_system_id = aws_efs_file_system.nfs.id
  subnet_id = data.aws_cloudformation_export.public_subnet_2_id.value
}

module "eks" {
  source = "terraform-aws-modules/eks/aws"
  cluster_name = "xilution-k8s"
  cluster_version = "1.14"
  write_kubeconfig = false
  manage_aws_auth = false
  write_aws_auth_config = true
  subnets = [
    data.aws_cloudformation_export.public_subnet_1_id.value,
    data.aws_cloudformation_export.public_subnet_2_id.value
  ]
  vpc_id = data.aws_cloudformation_export.vpc_id.value
  worker_groups = [
    {
      instance_type = "t3.medium"
      asg_max_size = 4
      asg_min_size = 1
      asg_desired_capacity = 2
      tags = [
        {
          key = "xilution_organization_id"
          value = var.organization_id
          propagate_at_launch = true
        }
      ]
    }
  ]
  tags = {
    xilution_organization_id = var.organization_id
  }
}
