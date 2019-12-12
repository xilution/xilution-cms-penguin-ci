data "aws_vpc" "vpc" {
  tags {
    Name = "xilution"
  }
}

data "aws_subnet" "public_subnet_1" {
  tags {
    Name = "xilution-public-subnet-1"
  }
}

data "aws_subnet" "public_subnet_2" {
  tags {
    Name = "xilution-public-subnet-2"
  }
}

resource "aws_security_group" "mysql_security_group" {
  name = "allow-mysql-in"
  description = "Allow inbound MySQL traffic to RDS Cluster"
  vpc_id = data.aws_vpc.vpc.id
  ingress {
    from_port = 3306
    protocol = "tcp"
    to_port = 3306
    cidr_blocks = [
      data.aws_vpc.vpc.cidr_block
    ]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
  tags = {
    xilution_organization_id = var.organization_id
    originator = "xilution.com"
  }
}

resource "aws_rds_cluster" "aurora" {
  cluster_identifier = "wordpress-rds-cluster-${var.organization_id}"
  engine = "aurora-mysql"
  engine_version = "5.7.mysql_aurora.2.03.2"
  master_username = var.master_username
  master_password = base64decode(var.master_password)
  backup_retention_period = 1
  db_subnet_group_name = aws_db_subnet_group.aurora.name
  skip_final_snapshot = true
  vpc_security_group_ids = [
    aws_security_group.mysql_security_group.id
  ]
  tags = {
    xilution_organization_id = var.organization_id
    originator = "xilution.com"
  }
}

resource "aws_rds_cluster_instance" "aurora" {
  count = "2"
  identifier = "wordpress-rds-instance-${var.organization_id}-${count.index}"
  engine = "aurora-mysql"
  engine_version = "5.7.mysql_aurora.2.03.2"
  cluster_identifier = aws_rds_cluster.aurora.id
  instance_class = "db.t2.small"
  db_subnet_group_name = aws_db_subnet_group.aurora.name
  tags = {
    xilution_organization_id = var.organization_id
    originator = "xilution.com"
  }
}

resource "aws_db_subnet_group" "aurora" {
  name = "wordpress-rds-subnet-group"
  subnet_ids = [
    data.aws_subnet.public_subnet_1.id,
    data.aws_subnet.public_subnet_2.id
  ]
  tags = {
    xilution_organization_id = var.organization_id
    originator = "xilution.com"
  }
}

resource "null_resource" "k8s_configure" {
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${var.k8s_cluster_name}"
  }
  provisioner "local-exec" {
    command = "/bin/bash ${path.module}/scripts/install-namespaces.sh"
  }
  provisioner "local-exec" {
    command = "/bin/bash ${path.module}/scripts/install-db-secret.sh ${var.master_password}"
  }
  provisioner "local-exec" {
    command = "/bin/bash ${path.module}/scripts/install-db-config-map.sh ${var.master_username} ${aws_rds_cluster.aurora.endpoint}"
  }
  provisioner "local-exec" {
    command = "/bin/bash ${path.module}/scripts/install-wp-persistent-volumn-claim.sh"
  }
}
