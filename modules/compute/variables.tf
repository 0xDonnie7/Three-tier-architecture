variable "name" {
  description = "Name prefix for all resources, e.g. threetier-dev"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs the instances launch into (one per AZ)"
  type        = list(string)
}

variable "target_group_arn" {
  description = "ALB target group the Auto Scaling Group registers instances with"
  type        = string
}

variable "alb_security_group_id" {
  description = "Security group of the ALB; the only source allowed to reach the app port"
  type        = string
}

variable "app_port" {
  description = "Port the application listens on"
  type        = number
  default     = 80
}

variable "instance_type" {
  description = "EC2 instance type (x86_64, since the AMI lookup is x86_64)"
  type        = string
  default     = "t3.micro"
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB"
  type        = number
  default     = 20
}

variable "min_size" {
  description = "Minimum number of instances"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of instances"
  type        = number
  default     = 4
}

variable "desired_capacity" {
  description = "Initial number of instances"
  type        = number
  default     = 2
}

variable "cpu_target_percent" {
  description = "Average CPU utilisation the Auto Scaling Group tries to maintain"
  type        = number
  default     = 50
}

variable "user_data" {
  description = "Startup script for the instances. If null, a placeholder Nginx page is installed (serves on port 80)"
  type        = string
  default     = null
}

variable "enable_db_secret_access" {
  description = "Grant the instances permission to read the database secret"
  type        = bool
  default     = false
}

variable "db_secret_arn" {
  description = "ARN of the Secrets Manager secret holding the DB credentials (used when enable_db_secret_access is true)"
  type        = string
  default     = null
}
