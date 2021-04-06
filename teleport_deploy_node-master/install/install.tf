provider "aws" {
  region  = "us-west-2"
}

data "aws_instance" "teleport_node" {

  filter {
    name   = "subnet-id"
    values = ["subnet-0392cbe2c3cd25882"]
  }

  filter {
    name   = "instance-state-name"
    values = ["running"]
  }

  filter {
    name   = "tag:Name"
    values = ["teleport_node"]
  }

}

resource "null_resource" "teleport_node_provisioner" {
  count = "length(data.aws_instance.teleport_node[private_ip])"

  provisioner "file" {
    source      = "/opt/teleport_deploy_node/file"
    destination = "/tmp"
  }
    
  provisioner "remote-exec" {
    inline = [
      "sudo tar -zxvf /tmp/file/teleport-v4.4.1-linux-amd64-bin.tar.gz",
      "sudo /tmp/file/teleport/install",
      "sudo rm -Rf /var/lib/teleport/*",
      "sudo mv -f /usr/local/bin/tctl /bin/",
      "sudo mv -f /usr/local/bin/teleport /bin/",
      "sudo mv -f /usr/local/bin/tsh /bin/",
      "sudo sed 's/teleport_node_private_ip/data.aws_instance.teleport_node.private_ip/g' /tmp/file/teleport.yaml.Node.txt > /tmp/teleport.yaml",
      "sudo sed -i 's/teleport_auth_CA_pin/var.teleport_auth_CA_pin/g' /tmp/teleport.yaml",
      "sudo mv -f /tmp/teleport.yaml /etc/teleport.yaml",
      "sudo bash -c 'cat /tmp/teleport_node/teleport.service.Node.txt > /etc/systemd/system/teleport.service'",
      "sudo chmod 644 /etc/systemd/system/teleport.service",
      "sudo systemctl restart teleport",
      "sleep 5"
    ]
  }

  connection {
      private_key = file("/opt/cloud-savvy-jenkins-dba.pem")
      host        = data.aws_instance.teleport_node[count.index].private_ip
      user        = "ec2-user"
    }
}
