resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "redis-instance"
  engine               = "redis"
  engine_version       = "6.x"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis6.x"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.redis_subnet_group.name
  security_group_ids   = [var.redis_sg]
}
resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = "redis-subnet-group"
  description = "Subnets for Redis cluster"

  subnet_ids = [
    var.private_subnets_1_ids,
    var.private_subnets_2_ids,
  ]
}