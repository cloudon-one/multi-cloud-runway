variable "instances" {
  description = "List of EC2 instances to create"
  type = list(object({
    name                        = string
    ami                         = string
    availability_zone           = string
    private_ip                  = string
    associate_public_ip_address = string
    subnet_id                   = string
    instance_type               = string
    ebs_block_device            = list(string)
    tags                        = map(string)
  }))
}