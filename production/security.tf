resource "yandex_vpc_security_group" "bastion_sg" {
  name        = "Bastion SG"
  description = "Bastion connections"
  network_id  = yandex_vpc_network.k8s_vpc.id

  ingress {
    protocol       = "TCP"
    description    = "SSH connection from external host"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  egress {
    protocol       = "ANY"
    description    = "outbound traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "k8s_sg" {
  name        = "K8s hosts SG"
  description = "SG for hosts in k8s cluster"
  network_id  = yandex_vpc_network.k8s_vpc.id

  ingress {
    protocol          = "TCP"
    description       = "SSH connection from Jump VM"
    security_group_id = yandex_vpc_security_group.bastion_sg.id
    port              = 22
  }

  ingress {
    protocol          = "ICMP"
    description       = "ICMP from Jump VM"
    security_group_id = yandex_vpc_security_group.bastion_sg.id
  }

  ingress {
    protocol          = "ICMP"
    description       = "ICMP"
    predefined_target = "self_security_group"
  }

  egress {
    protocol       = "ANY"
    description    = "outbound traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}