variable "auto_accept" {
  type        = bool
  default     = true
  description = "Automatically accept the peering"
}

variable "accepter_enabled" {
  description = "Flag to enable/disable the accepter side of the peering connection"
  type        = bool
  default     = true
}

variable "accepter_aws_access_key" {
  description = "Access key id to use in accepter account"
  type        = string
  default     = null
}

variable "accepter_aws_profile" {
  description = "Profile used to assume accepter_aws_assume_role_arn"
  type        = string
  default     = ""
}

variable "accepter_aws_assume_role_arn" {
  description = "Accepter AWS Assume Role ARN"
  type        = string
  default     = null
}

variable "accepter_aws_secret_key" {
  description = "Secret access key to use in accepter account"
  type        = string
  default     = null
}

variable "accepter_aws_token" {
  description = "Session token for validating temporary credentials"
  type        = string
  default     = null
}

variable "accepter_region" {
  type        = string
  description = "Accepter AWS region"
}

variable "accepter_vpc_id" {
  type        = string
  description = "Accepter VPC ID filter"
  default     = ""
}

variable "accepter_vpc_tags" {
  type        = map(string)
  description = "Accepter VPC Tags filter"
  default     = {}
}

variable "accepter_subnet_tags" {
  type        = map(string)
  description = "Only add peer routes to accepter VPC route tables of subnets matching these tags"
  default     = {}
}

variable "accepter_allow_remote_vpc_dns_resolution" {
  type        = bool
  default     = true
  description = "Allow accepter VPC to resolve public DNS hostnames to private IP addresses when queried from instances in the requester VPC"
}

variable "skip_metadata_api_check" {
  type        = bool
  default     = false
  description = "Don't use the credentials of EC2 instance profile"
}

variable "add_attribute_tag" {
  type        = bool
  default     = true
  description = "If `true` will add additional attribute tag to the requester and accceptor resources"
}

variable "aws_route_create_timeout" {
  type        = string
  default     = "5m"
  description = "Time to wait for AWS route creation specifed as a Go Duration, e.g. `2m`"
}

variable "aws_route_delete_timeout" {
  type        = string
  default     = "5m"
  description = "Time to wait for AWS route deletion specifed as a Go Duration, e.g. `5m`"
}

variable "requester_aws_assume_role_arn" {
  description = "Requester AWS Assume Role ARN"
  type        = string
  default     = null
}

variable "requester_region" {
  type        = string
  description = "Requester AWS region"
  default = null
}

variable "additional_tag_map" {
  type        = map(string)
  description = "Additional tags for the peering connection"
  default     = {}
}

variable "attributes" {
  type = list(string)
  description = "D element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`, in the order they appear in the list. New attributes are appended to the end of the list. The elements of the list are joined by the `delimiter` and treated as a single ID element."
  default = []
}

variable "context" {
  type        = any
  description = "Single object for setting entire context at once. See description of individual variables for details. Leave string and numeric variables as `null` to use default value. Individual variable settings (non-null) override settings in context object, except for attributes, tags, and additional_tag_map, which are merged."
  default     = {
    "additional_tag_map": {}, 
    "attributes": [], 
    "delimiter": null, 
    "descriptor_formats": {}, 
    "enabled": true, "environment": null, 
    "id_length_limit": null, 
    "label_key_case": null, 
    "label_order": [], 
    "label_value_case": null, 
    "labels_as_tags": [ "unset" ], 
    "name": null, 
    "namespace": null, 
    "regex_replace_chars": null, 
    "stage": null, "tags": {}, 
    "tenant": null
  }
}

variable "delimiter" {
  type        = string
  description = "Delimiter to be used between ID elements. Defaults to `-` (hyphen). Set to `` to use no delimiter at all."
  default     = null
}

variable "descriptor_formats" {
  type = any
  description = "Describe additional descriptors to be output in the `descriptors` output map. Map of maps. Keys are names of descriptors. Values are maps of the form `{ format = string labels = list(string) }` (Type is `any` so the map values can later be enhanced to provide additional options.) `format` is a Terraform format string to be passed to the `format()` function. `labels` is a list of labels, in order, to pass to `format()` function. Label values will be normalized before being passed to `format()` so they will be identical to how they appear in `id`. Default is `{}` (`descriptors` output will be empty)."
  default = {}
}

variable "enabled" {
  type        = bool
  description = "Set to `false` to prevent the module from creating any resources"
  default     = true
}

variable "environment" {
  type        = string
  description = "Environment, e.g. 'staging', 'production', 'dev', or 'shared'"
  default     = null
}

variable "id_length_limit" {
  type        = number
  description = "Maximum length of generated IDs"
  default     = null
}

variable "label_key_case" {
  type        = string
  description = "Case of labels keys. One of `title`, `upper`, `lower`, or `unchanged`"
  default     = null
}

variable "label_order" {
  type = list(string)
  description = "Controls the letter case of ID elements (labels) as included in `id`, set as tag values, and output by this module individually. Does not affect values of tags passed in via the `tags` input. Possible values: `lower`, `title`, `upper` and `none` (no transformation). Set this to `title` and set `delimiter` to `` to yield Pascal Case IDs. Default value: `lower`."
  default = null
}

variable "label_value_case" {
  type        = string
  description = "Case of labels values. One of `title`, `upper`, `lower`, or `unchanged`"
  default     = null
}

variable "labels_as_tags" {
  type        = list(string)
  description = "List of labels to use as tags. Default is `[]` (no tags)."
  default     = []
}

variable "name" {
  type = string
  description = "ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'. This is the only ID element not also included as a `tag`. The name tag is set to the full `id` string. There is no tag with the value of the `name` input."
  default = null
}

variable "namespace" {
  type = string
  description = "Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique"
  default = null
}

variable "regex_replace_chars" {
  type = string
  description = "Terraform regular expression (regex) string. Characters matching the regex will be removed from the ID elements. If not set, `"/[a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits."
  default = null
}

variable "requester_allow_remote_vpc_dns_resolution" {
  type        = bool
  description = "Allow requester VPC to resolve public DNS hostnames to private IP addresses when queried from instances in the accepter VPC"
  default     = true
}

variable "requester_aws_access_key" {
  type        = string
  description = "Access key id to use in requester account"
  default     = null
}

variable "requester_aws_profile" {
  type        = string
  description = "Profile used to assume requester_aws_assume_role_arn"
  default     = ""
}

variable "requester_aws_secret_key" {
  type = string
  description = "Access key id to use in requester account"
  default = null
}

variable "requester_aws_token" {
  type = string
  description = "Session token for validating temporary credentials"
  default = null
}

variable "requester_vpc_id" {
  type = string
  description = "Requester VPC ID filter"
  default = ""
}

variable "requester_vpc_tags" {
  type = map(string)
  description = "Requester VPC Tags filter"
  default = {}
}

variable "requester_subnet_tags" {
  type = map(string)
    description = "Only add peer routes to requester VPC route tables of subnets matching these tags"
    default = {}
}

variable "stage" {
  type = string
  description = "Stage, e.g. 'prod', 'staging', 'dev', or 'test'"
  default = null
}

variable "tags" {
  type = map(string)
  description = "Map of tags to add to the resources"
  default = {}
}

variable "tenant" {
  type = string
  description = "Tenant or client account name, a team or an organization"
  default = null
}