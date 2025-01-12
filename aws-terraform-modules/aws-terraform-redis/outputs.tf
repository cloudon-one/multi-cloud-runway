output "cluster_id" {
  description = "The ID of the ElastiCache cluster"
  value       = aws_elasticache_cluster.this.id
}

output "cluster_address" {
  description = "The DNS name of the cache cluster without the port appended"
  value       = aws_elasticache_cluster.this.cache_nodes[0].address
}

output "cluster_port" {
  description = "The port number on which the cache accepts connections"
  value       = aws_elasticache_cluster.this.port
}
