resource "aws_db_instance" "postgres" {
  allocated_storage      = 20 # Размер хранилища в гигабайтах
  storage_type           = "gp2"
  engine                 = "postgres"
  engine_version         = "16.6"
  instance_class         = var.db_instance_class
  db_name                = var.db_name # Имя базы данных
  username               = var.db_username # Имя пользователя
  password               = var.db_password # Пароль
  skip_final_snapshot    = true # Пропустить создание финального снепшота при удалении
  publicly_accessible    = false # Доступен ли инстанс публично (рекомендуется false)
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = [var.rds_security_group_id] # ID группы безопасности
}
