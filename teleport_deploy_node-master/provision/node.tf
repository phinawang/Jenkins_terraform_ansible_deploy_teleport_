provider "aws" {
  region  = "us-west-2"
}

resource "aws_instance" "teleport_node" {
  ami           = var.ec2_ami
  instance_type = "t2.micro"
  subnet_id = var.ec2_subnet_id
  associate_public_ip_address  = false
  vpc_security_group_ids = [
        var.security_group_id
      ]
  tags =  {
        "Name" = "teleport_node"
        }
  key_name      = var.ssh_key_name
  count = "3"
}


output "teleport_node_private_ip" {
  value = aws_instance.teleport_node.*.private_ip
}

output "teleport_node_instance_id" {
  value = aws_instance.teleport_node.*.id
}
