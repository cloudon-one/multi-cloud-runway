resource "aws_instance" "this" {
  count                       = length(var.instances)
  ami                         = var.instances[count.index].ami
  instance_type               = var.instances[count.index].instance_type
  availability_zone           = var.instances[count.index].availability_zone
  subnet_id                   = var.instances[count.index].subnet_id
  private_ip                  = var.instances[count.index].private_ip
  associate_public_ip_address = var.instances[count.index].associate_public_ip_address != "null"

  tags = var.instances[count.index].tags

  root_block_device {
    delete_on_termination = true
  }

  lifecycle {
    ignore_changes = [ebs_block_device]
  }
}

resource "aws_ebs_volume" "this" {
  count             = sum([for instance in var.instances : length(instance.ebs_block_device)])
  availability_zone = var.instances[index(var.instances.*.name, element(flatten([for i, instance in var.instances : [for j, _ in instance.ebs_block_device : instance.name]]), count.index))].availability_zone
  size              = 8  # Default size, adjust as needed

  tags = {
    Name = "EBS volume for ${element(flatten([for i, instance in var.instances : [for j, _ in instance.ebs_block_device : instance.name]]), count.index)}"
  }
}

resource "aws_volume_attachment" "this" {
  count       = sum([for instance in var.instances : length(instance.ebs_block_device)])
  device_name = "/dev/sdf"  # Adjust as needed
  volume_id   = aws_ebs_volume.this[count.index].id
  instance_id = aws_instance.this[index(var.instances.*.name, element(flatten([for i, instance in var.instances : [for j, _ in instance.ebs_block_device : instance.name]]), count.index))].id
}