output "alb_dns_name" {
  description = "Public DNS name of the application load balancer"
  value       = module.alb.alb_dns_name
}

output "autoscaling_group_name" {
  description = "Application Auto Scaling Group name"
  value       = module.compute.autoscaling_group_name
}

output "database_endpoint" {
  description = "Private PostgreSQL endpoint"
  value       = module.database.db_endpoint
}

output "database_name" {
  description = "Initial PostgreSQL database name"
  value       = module.database.db_name
}

output "database_secret_arn" {
  description = "Secrets Manager ARN for the generated database credentials"
  value       = module.database.master_user_secret_arn
}
