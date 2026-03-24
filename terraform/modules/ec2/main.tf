data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_key_pair" "bastion_key" {
  key_name   = "terraform-bastion-key"
  public_key = var.public_key
}

resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.bastion_sg]

  key_name = aws_key_pair.bastion_key.key_name

  associate_public_ip_address = true

  tags = {
    Name = "bastion-host"
  }
}

resource "aws_instance" "app" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [var.app_sg]

  key_name = aws_key_pair.bastion_key.key_name

  tags = {
    Name = "private-app-server"
  }
}
resource "aws_eip" "bastion_eip" {
  instance = aws_instance.bastion.id
  domain   = "vpc"

  tags = {
    Name = "bastion-eip"
  }
}
resource "aws_cloudwatch_metric_alarm" "bastion_status_check" {
  alarm_name          = "bastion-status-check-failed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Maximum"
  threshold           = 0

  dimensions = {
    InstanceId = aws_instance.bastion.id
  }
}
resource "aws_cloudwatch_metric_alarm" "bastion_network_in" {
  alarm_name          = "bastion-network-in-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "NetworkIn"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 10000000

  dimensions = {
    InstanceId = aws_instance.bastion.id
  }
}
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "infrastructure-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric",
        x    = 0,
        y    = 0,
        width  = 12,
        height = 6,

        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", "InstanceId", aws_instance.bastion.id]
          ],
          period = 300,
          stat   = "Average",
          region = "ca-central-1",
          title  = "EC2 CPU Usage"
        }
      }
    ]
  })
}
resource "aws_sns_topic" "alerts" {
  name = "infrastructure-alerts"
}
resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "moahmedhajir36@gmail.com"
}
resource "aws_cloudwatch_metric_alarm" "bastion_cpu_high" {
  alarm_name          = "bastion-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 70

  dimensions = {
    InstanceId = aws_instance.bastion.id
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}