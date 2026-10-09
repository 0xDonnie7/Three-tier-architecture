resource "aws_security_group" "db" {
  name_prefix = "${var.name}-db-"
  description = "Allow PostgreSQL traffic only from the application instances"
  vpc_id      = var.vpc_id

  tags = { Name = "${var.name}-db-sg" }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "postgres_from_app" {
  security_group_id            = aws_security_group.db.id
  referenced_security_group_id = var.app_security_group_id
  description                  = "PostgreSQL from application instances"
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}

resource "aws_db_subnet_group" "main" {
  name_prefix = "${var.name}-db-"
  description = "Private subnets for ${var.name} PostgreSQL"
  subnet_ids  = var.private_subnet_ids

  tags = { Name = "${var.name}-db-subnets" }
}

resource "aws_db_instance" "main" {
  identifier_prefix = "${var.name}-db-"

  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class

  db_name  = var.db_name
  username = var.username

  manage_master_user_password = true

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db.id]
  publicly_accessible    = false

  multi_az                   = var.multi_az
  backup_retention_period    = var.backup_retention_period
  deletion_protection        = var.deletion_protection
  skip_final_snapshot        = var.skip_final_snapshot
  final_snapshot_identifier  = var.skip_final_snapshot ? null : "${var.name}-final"
  apply_immediately          = var.apply_immediately
  auto_minor_version_upgrade = true
  copy_tags_to_snapshot      = true

  tags = { Name = "${var.name}-db" }
}
