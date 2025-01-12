variable "host_filters" {
  default     = []
  description = "List of key:value pairs for host tags / labels to filter Datadog montoring"
  type        = list(string)
}

variable "project_id" {
  description = "The ID of the GCP project that the service account will be created in."
  default     = ""
}

variable datadog_api_key {
  description = "Datadog API key, should be uniqe for US/EU"
  default     = ""
}

variable datadog_app_key {
  description = "Datadog APP key, should be uniqe for US/EU"
  default     = ""
}