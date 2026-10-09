variable "name" {
  description = "Name prefix for all resources, e.g. threetier-dev (keep short: ALB names max out at 32 characters)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC the ALB and target group live in"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for the ALB (one per AZ)"
  type        = list(string)
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
  description = "ACM certificate ARN. If set, enables HTTPS on 443 and redirects HTTP to HTTPS"
  type        = string
  default     = null
}

variable "enable_deletion_protection" {
  description = "Protect the ALB from accidental deletion (turn on for prod)"
  type        = bool
  default     = false
}
