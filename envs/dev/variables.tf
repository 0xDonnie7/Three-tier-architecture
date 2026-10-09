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
  description = "Whether to use a single NAT Gateway for all private subnets"
  type        = bool
  default     = true
}

variable "app_port" { type = number }
variable "health_check_path" { type = string }
variable "instance_type" { type = string }
variable "min_size" { type = number }
variable "max_size" { type = number }
variable "desired_capacity" { type = number }

variable "user_data" {
  description = "Optional EC2 startup script; defaults to a placeholder Nginx page"
  type        = string
  default     = null
}

variable "certificate_arn" {
  description = "Optional ACM certificate ARN for HTTPS"
  type        = string
  default     = null
}

variable "alb_deletion_protection" {
  description = "Protect the ALB from accidental deletion"
  type        = bool
  default     = false
}

variable "db_instance_class" { type = string }
variable "db_multi_az" { type = bool }
variable "db_backup_retention_period" { type = number }
variable "db_skip_final_snapshot" { type = bool }
variable "db_deletion_protection" { type = bool }
