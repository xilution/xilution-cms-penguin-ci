provider "aws" {
  profile = "xilution-test"
  region  = "us-east-1"
}

resource "aws_eks_cluster" "kubernetes" {
  name = "cluster"
  role_arn = "something"
  vpc_config {
    subnet_ids = []
  }
}

resource "aws_efs_file_system" "nfs" {

}
