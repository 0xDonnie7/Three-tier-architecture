environment        = "dev"
aws_region         = "us-east-1"
single_nat_gateway = true
app_port           = 80
health_check_path  = "/"
instance_type      = "t3.micro"
min_size           = 1
max_size           = 2
desired_capacity   = 1

db_instance_class          = "db.t4g.micro"
db_multi_az                = false
db_backup_retention_period = 1
db_skip_final_snapshot     = true
db_deletion_protection     = false

