resource "google_compute_firewall" "firewalls" {
  for_each = var.firewalls
  name     = each.key
  network  = each.value.network_name
  project  = each.value.project_id
  dynamic "allow" {
    for_each = each.value.allow
    content {
      protocol = allow.value.protocol
      ports    = allow.value.ports
    }
  }
  dynamic "deny" {
    for_each = each.value.deny
    content {
      protocol = deny.value.protocol
      ports    = deny.value.ports
    }
  }
  destination_ranges      = each.value.destination_ranges
  source_ranges           = each.value.source_ranges
  target_service_accounts = each.value.target_service_accounts
  target_tags             = each.value.target_tags
  priority                = each.value.priority
  dynamic "log_config" {
    for_each = each.value.log_config
    content {
      metadata = log_config.value.metadata
    }
  }
}