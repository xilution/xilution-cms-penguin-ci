data "aws_vpc" "vpc" {
  filter {
    name = "tag:Name"
    values = [
      "xilution"
    ]
  }
}

data "aws_subnet" "public_subnet_1" {
  filter {
    name = "tag:Name"
    values = [
      "xilution-public-subnet-1"
    ]
  }
}

data "aws_subnet" "public_subnet_2" {
  filter {
    name = "tag:Name"
    values = [
      "xilution-public-subnet-2"
    ]
  }
}

data "aws_iam_role" "cloudwatch-events-rule-invocation-role" {
  name = "xilution-cloudwatch-events-rule-invocation-role"
}

data "aws_lambda_function" "metrics-reporter-lambda" {
  function_name = "xilution-client-metrics-reporter-lambda"
}

# Database

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
    command = "/bin/bash ${path.module}/scripts/install-regcred-secret.sh ${var.docker_username} ${var.docker_password}"
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

# Metrics

resource "aws_cloudwatch_event_rule" "penguin-cloudwatch-every-ten-minute-event-rule" {
  name = "penguin-${var.pipeline_id}-cloudwatch-event-rule"
  schedule_expression = "rate(10 minutes)"
  role_arn = data.aws_iam_role.cloudwatch-events-rule-invocation-role.arn
  tags = {
    xilution_organization_id = var.organization_id
    originator = "xilution.com"
  }
}

resource "aws_cloudwatch_event_target" "penguin-cloudwatch-event-target" {
  rule = aws_cloudwatch_event_rule.penguin-cloudwatch-every-ten-minute-event-rule
  arn = data.aws_lambda_function.metrics-reporter-lambda.arn
  input = <<-DOC
  {
    "Duration": 600000,
    "MetricDataQueries": [
      {
        "Id": "${uuid()}",
        "MetricStat": {
          "Metric": {
            "Namespace": "string",
            "MetricName": "string",
            "Dimensions": [
              {
                "Name": "string",
                "Value": "string"
              }
            ]
          },
          "Period": integer,
          "Stat": "string",
          "Unit": "string"
        },
        "Expression": "string",
        "Label": "string",
        "ReturnData": boolean,
        "Period": integer
      }
    ]
  }
  DOC
}

# Dashboards

resource "aws_cloudwatch_dashboard" "penguin-cloudwatch-dashboard" {
  dashboard_name = "xilution-penguin-${var.pipeline_id}-dashboard"

  dashboard_body = <<-EOF
  {
    "widgets": [
      {
        "type":"metric",
        "x":0,
        "y":0,
        "width":3,
        "height":3,
        "properties":{
          "markdown":"Hello world"
        }
      }
    ]
  }
  EOF
  tags = {
    xilution_organization_id = var.organization_id
    originator = "xilution.com"
  }
}
