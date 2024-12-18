resource "aws_elasticache_cluster" "redis" {
  cluster_id           = local.cluster_id
  engine               = local.engine
  engine_version       = local.engine_version
  node_type            = local.node_type
  num_cache_nodes      = local.num_cache_nodes
  parameter_group_name = local.parameter_group_name
  port                 = local.port
  subnet_group_name    = aws_elasticache_subnet_group.redis_subnet_group.name
  security_group_ids   = [var.redis_sg]
}

resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name                 = "redis-subnet-group"
  description          = "Subnets for Redis cluster"

  subnet_ids = [
    var.private_subnets_1_ids,
    var.private_subnets_2_ids,
  ]
}