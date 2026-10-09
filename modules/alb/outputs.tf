output "alb_security_group_id" {
  description = "Security group of the ALB (the app instances allow traffic from this)"
  value       = aws_security_group.alb.id
}

output "target_group_arn" {
  description = "Target group the Auto Scaling Group attaches to"
  value       = aws_lb_target_group.app.arn
}

output "alb_dns_name" {
  description = "Public DNS name of the ALB"
  value       = aws_lb.main.dns_name
}

output "alb_arn" {
  description = "ARN of the ALB"
  value       = aws_lb.main.arn
}

output "alb_zone_id" {
  description = "Hosted zone ID of the ALB (for Route 53 alias records)"
  value       = aws_lb.main.zone_id
}
