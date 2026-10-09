output "app_security_group_id" {
  description = "Security group of the app instances (the database allows traffic from this)"
  value       = aws_security_group.app.id
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.app.name
}

output "launch_template_id" {
  description = "ID of the launch template"
  value       = aws_launch_template.app.id
}

output "iam_role_name" {
  description = "Name of the instance IAM role (attach extra policies here if the app needs them)"
  value       = aws_iam_role.app.name
}
