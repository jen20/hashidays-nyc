resource "aws_security_group" "consul_server" {
	name = "consul-server-sg"
	description = "Security group for Consul Server Instances"
	vpc_id = "${var.vpc_id}"

	tags {
		Name = "Consul Server (${var.cluster_name})"
	}

	# SSH
	ingress {
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	# DNS (TCP)
	ingress {
		from_port = 8600
		to_port = 8600
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	# DNS (UDP)
	ingress {
		from_port = 8600
		to_port = 8600
		protocol = "udp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	# HTTP
	ingress {
		from_port = 8500
		to_port = 8500
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	# Serf (TCP)
	ingress {
		from_port = 8301
		to_port = 8302
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	# Serf (UDP)
	ingress {
		from_port = 8301
		to_port = 8302
		protocol = "udp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	# Server RPC
	ingress {
		from_port = 8300
		to_port = 8300
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	# TCP All outbound traffic
	egress {
		from_port = 0
		to_port = 65535
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	# UDP All outbound traffic
	egress {
		from_port = 0
		to_port = 65535
		protocol = "udp"
		cidr_blocks = ["0.0.0.0/0"]
	}
}

resource "aws_security_group" "consul_client" {
	name        = "consul-sg"
	description = "Security group for Consul Agent client instances"
	vpc_id      = "${var.vpc_id}"

	tags {
		Name = "Consul Client (${var.cluster_name})"
		ConsulCluster = "${replace(var.cluster_name, " ", "")}"
	}

	# Serf (TCP)
	ingress {
		from_port   = 8301
		to_port     = 8302
		protocol    = "tcp"
		self = true
	}

	# Serf (UDP)
	ingress {
		from_port   = 8301
		to_port     = 8302
		protocol    = "udp"
		self = true
	}

	# Server RPC
	ingress {
		from_port   = 8300
		to_port     = 8300
		protocol    = "tcp"
		self = true
	}

	# TCP All outbound traffic
	egress {
		from_port   = 0
		to_port     = 65535
		protocol    = "tcp"
		self = true
	}

	# UDP All outbound traffic
	egress {
		from_port   = 0
		to_port     = 65535
		protocol    = "udp"
		self = true
	}
}
