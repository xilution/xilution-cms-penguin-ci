data "aws_iam_role" "cloudwatch-events-rule-invocation-role" {
  name = "xilution-cloudwatch-events-rule-invocation-role"
}

data "aws_lambda_function" "metrics-reporter-lambda" {
  function_name = "xilution-client-metrics-reporter-lambda"
}

resource "null_resource" "k8s_configure" {
  triggers = {
    always_run = timestamp()
  }
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
    command    = "/bin/bash ${path.module}/scripts/install-regcred-secret.sh ${var.docker_username} ${var.docker_password}"
    on_failure = "continue"
  }
  provisioner "local-exec" {
    command = "/bin/bash ${path.module}/scripts/install-wp-persistent-volumn-claim.sh"
  }
}

# Data Transfer

locals {
  k8s_data_transfer_bucket_name = "xilution-penguin-${substr(var.penguin_pipeline_id, 0, 8)}-data-transfer"
}

resource "aws_s3_bucket" "k8s_data_transfer_bucket" {
  bucket = local.k8s_data_transfer_bucket_name
}

# Metrics

resource "aws_lambda_permission" "allow-penguin-cloudwatch-every-ten-minute-event-rule" {
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.metrics-reporter-lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.penguin-cloudwatch-every-ten-minute-event-rule.arn
}

resource "aws_cloudwatch_event_rule" "penguin-cloudwatch-every-ten-minute-event-rule" {
  name                = "xilution-penguin-${substr(var.penguin_pipeline_id, 0, 8)}-cloudwatch-event-rule"
  schedule_expression = "rate(10 minutes)"
  role_arn            = data.aws_iam_role.cloudwatch-events-rule-invocation-role.arn
  tags = {
    xilution_organization_id = var.organization_id
    originator               = "xilution.com"
  }
}

resource "aws_cloudwatch_event_target" "penguin-cloudwatch-event-target" {
  rule  = aws_cloudwatch_event_rule.penguin-cloudwatch-every-ten-minute-event-rule.name
  arn   = data.aws_lambda_function.metrics-reporter-lambda.arn
  input = <<-DOC
  {
    "Environment": "prod",
    "OrganizationId": "${var.organization_id}",
    "ProductId": "${var.product_id}",
    "Duration": 600000,
    "MetricDataQueries": [
      {
        "Id": "client_metrics_reporter_lambda_duration",
        "MetricStat": {
          "Metric": {
            "Namespace": "AWS/Lambda",
            "MetricName": "Duration",
            "Dimensions": [
              {
                "Name": "FunctionName",
                "Value": "xilution-client-metrics-reporter-lambda"
              }
            ]
          },
          "Period": 60,
          "Stat": "Average",
          "Unit": "Milliseconds"
        }
      }
    ],
    "MetricNameMaps": [
      {
        "Id": "client_metrics_reporter_lambda_duration",
        "MetricName": "client-metrics-reporter-lambda-duration"
      }
    ]
  }
  DOC
}

# Dashboards

resource "aws_cloudwatch_dashboard" "penguin-cloudwatch-dashboard" {
  dashboard_name = "xilution-penguin-${substr(var.penguin_pipeline_id, 0, 8)}-dashboard"

  dashboard_body = <<-EOF
  {
    "widgets": [
      {
        "type": "metric",
        "x": 0,
        "y": 0,
        "width": 12,
        "height": 6,
        "properties": {
          "metrics": [
            [
              "AWS/EC2",
              "CPUUtilization",
              "InstanceId",
              "i-012345"
            ]
          ],
          "period": 300,
          "stat": "Average",
          "region": "us-east-1",
          "title": "EC2 Instance CPU"
        }
      },
      {
        "type": "text",
        "x": 0,
        "y": 7,
        "width": 3,
        "height": 3,
        "properties": {
          "markdown": "Hello world"
        }
      }
    ]
  }
  EOF
}
