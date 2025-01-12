# AWS EC2 Instance Terraform Module

This Terraform module creates and manages AWS EC2 instances with optional EBS volume attachments.

## Features

- Create multiple EC2 instances
- Configure instance details such as AMI, instance type, availability zone, subnet, and IP addresses
- Attach additional EBS volumes to instances
- Customizable tags for instances and EBS volumes

## Usage

```hcl
module "ec2_instances" {
  source = "./path/to/this/module"

  instances = [
    {
      name                        = "instance-1"
      ami                         = "ami-12345678"
      instance_type               = "t2.micro"
      availability_zone           = "us-west-2a"
      subnet_id                   = "subnet-12345678"
      private_ip                  = "10.0.1.10"
      associate_public_ip_address = true
      tags = {
        Name = "Instance 1"
        Environment = "Production"
      }
      ebs_block_device = [
        {
          device_name = "/dev/sdf"
          volume_size = 20
        }
      ]
    },
    {
      name                        = "instance-2"
      ami                         = "ami-87654321"
      instance_type               = "t2.small"
      availability_zone           = "us-west-2b"
      subnet_id                   = "subnet-87654321"
      private_ip                  = "10.0.2.10"
      associate_public_ip_address = false
      tags = {
        Name = "Instance 2"
        Environment = "Staging"
      }
      ebs_block_device = []
    }
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| instances | List of EC2 instance configurations | `list(object)` | `[]` | yes |

Each object in the `instances` list should have the following structure:

```hcl
{
  name                        = string
  ami                         = string
  instance_type               = string
  availability_zone           = string
  subnet_id                   = string
  private_ip                  = string
  associate_public_ip_address = bool
  tags                        = map(string)
  ebs_block_device            = list(object({
    device_name = string
    volume_size = number
  }))
}
```

## Resources Created

- `aws_instance`: EC2 instances
- `aws_ebs_volume`: EBS volumes (if specified in instance configuration)
- `aws_volume_attachment`: Attachments between EBS volumes and EC2 instances

## Notes

1. The root block device for all instances is set to be deleted on termination.
2. The module ignores changes to the `ebs_block_device` attribute of the EC2 instances to prevent Terraform from attempting to manage EBS volumes attached outside of this module.
3. Additional EBS volumes are created with a default size of 8 GB. Adjust the `size` parameter in the `aws_ebs_volume` resource if you need different sizes.
4. Additional EBS volumes are attached with a default device name of "/dev/sdf". Adjust the `device_name` parameter in the `aws_volume_attachment` resource if you need different device names.

## Limitations

1. This module doesn't support creating or managing security groups. You'll need to reference existing security groups in your VPC.
2. The module doesn't handle key pairs for SSH access. You'll need to manage these separately and reference them in your instance configurations if needed.
3. All additional EBS volumes are created with the same size. If you need different sizes for different volumes, you'll need to modify the module.

## Outputs

This module doesn't define any outputs. Consider adding outputs for instance IDs, public IPs, or other relevant information if needed for your use case.

## License

This module is open-source software licensed under the [MIT license](https://opensource.org/licenses/MIT).