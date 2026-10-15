variable "project" {
  description = "Project name, used as a prefix for resource names"
  type        = string
  default     = "threetier"
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of Availability Zones to use"
  type        = number
  default     = 2
}

variable "single_nat_gateway" {
  description = "Use one shared NAT Gateway instead of one per AZ"
  type        = bool
  default     = false
}

variable "app_port" {
  description = "Port the application listens on"
  type        = number
  default     = 80
}

variable "health_check_path" {
  description = "HTTP path the ALB uses to check instance health"
  type        = string
  default     = "/"
}

variable "certificate_arn" {
  description = "Optional ACM certificate ARN for HTTPS"
  type        = string
  default     = null
}

variable "alb_deletion_protection" {
  description = "Protect the production ALB from accidental deletion"
  type        = bool
  default     = true
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "min_size" {
  description = "Minimum application instance count"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum application instance count"
  type        = number
  default     = 4
}

variable "desired_capacity" {
  description = "Initial application instance count"
  type        = number
  default     = 2
}

variable "user_data" {
  description = "Optional EC2 startup script; defaults to a placeholder Nginx page"
  type        = string
  default     = null
}

variable "db_instance_class" {
  description = "RDS PostgreSQL instance class"
  type        = string
  default     = "db.t4g.small"
}

variable "db_multi_az" {
  description = "Enable RDS standby and automatic failover"
  type        = bool
  default     = true
}

variable "db_backup_retention_period" {
  description = "Automated backup retention in days"
  type        = number
  default     = 1
}

variable "db_skip_final_snapshot" {
  description = "Skip the final RDS snapshot when destroying the database"
  type        = bool
  default     = false
}

variable "db_deletion_protection" {
  description = "Protect the production database from accidental deletion"
  type        = bool
  default     = true
}
