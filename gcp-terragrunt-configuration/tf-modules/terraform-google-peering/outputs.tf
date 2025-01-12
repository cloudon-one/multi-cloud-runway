output "complete" {
  value       = module.peering-a-b.complete
  description = "Output to be used as a module dependency"
}

output "local_network_peering" {
  value = module.peering-a-b.local_network_peering
}

output "peer_network_peering" {
  value = module.peering-a-b.peer_network_peering
}

output "a_c_local_network_peering" {
  value = module.peering-a-c.local_network_peering
}

output "a_c_peer_network_peering" {
  value = module.peering-a-c.peer_network_peering
}
