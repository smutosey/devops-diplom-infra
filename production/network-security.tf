# Группа безопасности для NAT-инстанса/бастиона
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
    description    = "ext-http for connections"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "ext-https for connections"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }

  egress {
    protocol       = "ANY"
    description    = "outbound traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# Группа безопасности для нод кластера k8s
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
    description       = "SSH connection from other internal cluster hosts"
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
    description       = "ICMP between nodes"
    predefined_target = "self_security_group"
  }

  ingress {
    protocol          = "ANY"
    description       = "any traffic inside group"
    predefined_target = "self_security_group"
  }

  ingress {
    protocol          = "TCP"
    description       = "balancer"
    security_group_id = yandex_vpc_security_group.alb_sg.id
    port              = 80
  }

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
}

# Группа безопасности для application load balancer
resource "yandex_vpc_security_group" "alb_sg" {
  name       = "k8s-alb"
  network_id = yandex_vpc_network.k8s_vpc.id

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

  ingress {
    protocol          = "TCP"
    description       = "healthchecks"
    predefined_target = "loadbalancer_healthchecks"
    port              = 30080
  }

  egress {
    protocol       = "ANY"
    description    = "any"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
