output "firewalls" {
  description = "Map of created firewall resources"
  value       = google_compute_firewall.firewalls
}
