resource "yandex_vpc_security_group" "secure_bastion_sg" {
  name        = "secure_bastion_sg"
  description = "connection to bastion host 22 port"
  network_id  = yandex_vpc_network.bastion_vpc.id

  ingress {
    protocol       = "TCP"
    description    = "SSH connection from external host"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }
}

resource "yandex_vpc_security_group" "internal_bastion_sg" {
  name        = "internal_bastion_sg"
  description = "connection from bastion to other vm in secure group"
  network_id  = yandex_vpc_network.k8s_vpc.id

  ingress {
    protocol       = "TCP"
    description    = "SSH connection from external host"
    v4_cidr_blocks = ["0.0.0.0/0"]# ["10.0.1.254/32"]
    port           = 22
  }

  egress {
    protocol       = "ANY"
    description    = "SSH connection to hosts"
    # predefined_target = "self_security_group"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }
}