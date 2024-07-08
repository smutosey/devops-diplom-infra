resource "yandex_vpc_security_group" "bastion_sg" {
  name        = "Bastion-SG"
  description = "Bastion connections"
  network_id  = yandex_vpc_network.k8s_vpc.id

  ingress {
    protocol       = "TCP"
    description    = "SSH connection from external host"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "ext-http"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "ext-https"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }

  egress {
    protocol       = "ANY"
    description    = "outbound traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "k8s_sg" {
  name        = "K8s-SG"
  description = "SG for hosts in k8s cluster"
  network_id  = yandex_vpc_network.k8s_vpc.id

  ingress {
    protocol          = "TCP"
    description       = "SSH connection from Jump VM"
    security_group_id = yandex_vpc_security_group.bastion_sg.id
    port              = 22
  }

  ingress {
    protocol          = "TCP"
    description       = "SSH connection from other cluster hosts"
    predefined_target = "self_security_group"
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

  ingress {
    protocol          = "ANY"
    description       = "any traffic inside group"
    predefined_target = "self_security_group"
  }

  #   ingress {
  #     protocol       = "TCP"
  #     description    = "nginx"
  #     v4_cidr_blocks = ["0.0.0.0/0"]
  #     port           = 80
  #   }

  #   ingress {
  #     protocol       = "TCP"
  #     description    = "k8snginx"
  #     v4_cidr_blocks = ["0.0.0.0/0"]
  #     port           = 8081
  #   }

  ingress {
    protocol       = "TCP"
    description    = "kubeapi"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 6443
  }

  egress {
    protocol       = "ANY"
    description    = "outbound traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  #   ingress {
  #     protocol       = "ANY"
  #     description    = "outbound traffic"
  #     v4_cidr_blocks = ["0.0.0.0/0"]
  #   }
}