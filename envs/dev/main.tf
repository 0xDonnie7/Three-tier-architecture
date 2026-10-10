module "network" {
  source = "../../modules/network"

  name               = "${var.project}-${var.environment}"
  vpc_cidr           = var.vpc_cidr
  az_count           = var.az_count
  single_nat_gateway = var.single_nat_gateway
}

module "alb" {
  source = "../../modules/alb"

  name                       = "${var.project}-${var.environment}"
  vpc_id                     = module.network.vpc_id
  public_subnet_ids          = module.network.public_subnet_ids
  app_port                   = var.app_port
  health_check_path          = var.health_check_path
  certificate_arn            = var.certificate_arn
  enable_deletion_protection = var.alb_deletion_protection
}

module "compute" {
  source = "../../modules/compute"

  name                    = "${var.project}-${var.environment}"
  vpc_id                  = module.network.vpc_id
  private_subnet_ids      = module.network.private_subnet_ids
  target_group_arn        = module.alb.target_group_arn
  alb_security_group_id   = module.alb.alb_security_group_id
  app_port                = var.app_port
  instance_type           = var.instance_type
  min_size                = var.min_size
  max_size                = var.max_size
  desired_capacity        = var.desired_capacity
  user_data               = var.user_data
  enable_db_secret_access = true
  db_secret_arn           = module.database.master_user_secret_arn
}

module "database" {
  source = "../../modules/database"

  name                    = "${var.project}-${var.environment}"
  vpc_id                  = module.network.vpc_id
  private_subnet_ids      = module.network.private_subnet_ids
  app_security_group_id   = module.compute.app_security_group_id
  instance_class          = var.db_instance_class
  multi_az                = var.db_multi_az
  backup_retention_period = var.db_backup_retention_period
  skip_final_snapshot     = var.db_skip_final_snapshot
  deletion_protection     = var.db_deletion_protection
}
