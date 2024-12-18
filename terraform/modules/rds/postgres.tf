resource "aws_db_instance" "postgres" {
  allocated_storage        = local.allocated_storage
  storage_type             = local.storage_type
  engine                   = local.engine
  engine_version           = local.engine_version
  instance_class           = var.db_instance_class
  db_name                  = var.db_name
  username                 = var.db_username
  password                 = var.db_password
  skip_final_snapshot      = true
  publicly_accessible      = false # for public - no
  db_subnet_group_name     = var.db_subnet_group_name
  vpc_security_group_ids   = [var.rds_security_group_id]
}
