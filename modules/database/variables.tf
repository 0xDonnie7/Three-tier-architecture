variable "name" {
  description = "Name prefix for all resources, e.g. threetier-dev"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the DB subnet group (must span at least 2 AZs)"
  type        = list(string)
}

variable "app_security_group_id" {
  description = "Security group of the app instances; the only source allowed to reach the database"
  type        = string
}

variable "engine_version" {
  description = "PostgreSQL version. A major version like \"16\" lets AWS pick the latest minor"
  type        = string
  default     = "16"
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t4g.micro"
}

variable "allocated_storage" {
  description = "Initial storage in GiB"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Upper limit for storage autoscaling in GiB (0 disables autoscaling)"
  type        = number
  default     = 100
}

variable "db_name" {
  description = "Name of the initial database"
  type        = string
  default     = "appdb"
}

variable "username" {
  description = "Master username (the password is generated and kept in Secrets Manager)"
  type        = string
  default     = "dbadmin"
}

variable "multi_az" {
  description = "Create a standby in a second AZ with automatic failover"
  type        = bool
  default     = true
}

variable "backup_retention_period" {
  description = "Days to keep automated backups (0 disables them)"
  type        = number
  default     = 1
}

variable "skip_final_snapshot" {
  description = "Skip the final snapshot on destroy (true for dev, false for prod)"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Block deletion of the database (turn on for prod)"
  type        = bool
  default     = false
}

variable "apply_immediately" {
  description = "Apply changes right away instead of waiting for the maintenance window"
  type        = bool
  default     = false
}
