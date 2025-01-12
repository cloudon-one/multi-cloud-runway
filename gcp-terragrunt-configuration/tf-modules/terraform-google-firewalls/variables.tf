variable "firewalls" {
  description = "Mapping of firewall rules. Key = firewall name, Value = firewall config"
  type = map(object({
    network_name = string
    project_id   = string
    allow = list(object({
      protocol = string,
      ports    = list(string)
    }))
    deny = list(object({
      protocol = string,
      ports    = string
    }))
    destination_ranges      = set(string)
    source_ranges           = set(string)
    direction               = string
    disabled                = bool
    priority                = number
    source_service_accounts = set(string)
    source_tags             = set(string)
    target_service_accounts = set(string)
    target_tags             = set(string)
    log_config = set(object({
      metadata = string
    }))
  }))
  default = {}
}