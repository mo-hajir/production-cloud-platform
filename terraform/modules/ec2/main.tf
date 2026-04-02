data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_key_pair" "bastion_key" {
  key_name   = "terraform-bastion-key"
  public_key = var.public_key
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.bastion_sg]
  key_name               = aws_key_pair.bastion_key.key_name
  associate_public_ip_address = true
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  user_data = <<-EOF
#!/bin/bash
yum update -y
yum install -y amazon-cloudwatch-agent

cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<EOL
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/messages",
            "log_group_name": "/app/logs",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  }
}
EOL

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
  -s
EOF

  tags = {
    Name = "bastion-host"
  }
}

resource "aws_instance" "app" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [var.app_sg]
  key_name               = aws_key_pair.bastion_key.key_name


  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

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

resource "aws_sns_topic" "alerts" {
  name = "infrastructure-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "your-email@example.com"
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {

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

}

resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/app/logs"
  retention_in_days = 7


  alarm_actions = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "status_check" {
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

  alarm_actions = [aws_sns_topic.alerts.arn]

}