# ---------- AMI ----------

# Latest Amazon Linux 2023 (x86_64), resolved at plan time
data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

locals {
  # Placeholder app so you can confirm the ALB health checks pass.
  # Replace it by passing your own user_data.
  default_user_data = <<-EOT
    #!/bin/bash
    set -euxo pipefail
    dnf install -y nginx
    TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 60")
    INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
    AZ=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone)
    echo "<h1>${var.name}</h1><p>Instance: $INSTANCE_ID ($AZ)</p>" > /usr/share/nginx/html/index.html
    systemctl enable --now nginx
  EOT

  user_data = coalesce(var.user_data, local.default_user_data)
}

# ---------- IAM ----------

data "aws_iam_policy_document" "assume_ec2" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "app" {
  name_prefix        = "${var.name}-app-"
  assume_role_policy = data.aws_iam_policy_document.assume_ec2.json

  tags = { Name = "${var.name}-app-role" }
}

# Session Manager access: shell on the instances without SSH or a bastion
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.app.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Optional: let the app read the database credentials from Secrets Manager
data "aws_iam_policy_document" "db_secret" {
  count = var.enable_db_secret_access ? 1 : 0

  statement {
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [var.db_secret_arn]
  }
}

resource "aws_iam_role_policy" "db_secret" {
  count = var.enable_db_secret_access ? 1 : 0

  name_prefix = "${var.name}-db-secret-"
  role        = aws_iam_role.app.id
  policy      = data.aws_iam_policy_document.db_secret[0].json
}

resource "aws_iam_instance_profile" "app" {
  name_prefix = "${var.name}-app-"
  role        = aws_iam_role.app.name
}

# ---------- Security group ----------

resource "aws_security_group" "app" {
  name_prefix = "${var.name}-app-"
  description = "App instances: accept traffic only from the ALB"
  vpc_id      = var.vpc_id

  tags = { Name = "${var.name}-app-sg" }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "from_alb" {
  security_group_id            = aws_security_group.app.id
  description                  = "App port from the ALB"
  from_port                    = var.app_port
  to_port                      = var.app_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = var.alb_security_group_id
}

# Outbound goes through the NAT gateway (package installs, updates, SSM, etc.)
resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.app.id
  description       = "Allow all outbound"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# ---------- Launch template ----------

resource "aws_launch_template" "app" {
  name_prefix   = "${var.name}-app-"
  image_id      = data.aws_ssm_parameter.al2023.value
  instance_type = var.instance_type
  user_data     = base64encode(local.user_data)

  iam_instance_profile {
    arn = aws_iam_instance_profile.app.arn
  }

  vpc_security_group_ids = [aws_security_group.app.id]

  # IMDSv2 only
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.root_volume_size
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags          = { Name = "${var.name}-app" }
  }

  tag_specifications {
    resource_type = "volume"
    tags          = { Name = "${var.name}-app" }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ---------- Auto Scaling Group ----------

resource "aws_autoscaling_group" "app" {
  name_prefix         = "${var.name}-app-"
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity
  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns   = [var.target_group_arn]

  # Replace instances the ALB reports as unhealthy, not just ones EC2 reports as dead
  health_check_type         = "ELB"
  health_check_grace_period = 180

  launch_template {
    id      = aws_launch_template.app.id
    version = aws_launch_template.app.latest_version
  }

  # Roll instances automatically when the launch template changes
  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key                 = "Name"
    value               = "${var.name}-app"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }
}

# Scale out and in to hold average CPU near the target
resource "aws_autoscaling_policy" "cpu" {
  name                   = "${var.name}-cpu-target"
  autoscaling_group_name = aws_autoscaling_group.app.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = var.cpu_target_percent
  }
}
