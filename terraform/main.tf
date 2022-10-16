provider "aws" {
  region = lookup(var.props, "region")
}

resource "aws_instance" "nexus" {
  ami = lookup(var.props, "ami")
  instance_type = lookup(var.props, "type")
  associate_public_ip_address = lookup(var.props, "enable_ip")
  key_name = aws_key_pair.key_pair.key_name
  user_data = var.user_script != "" ? file(var.user_script) : ""
  tags = {
    Name = lookup(var.props, "name")
    Environment = var.env
    Type = var.name_tag
  }
  root_block_device {
    delete_on_termination = true
    volume_size = 10
    volume_type = "gp2"
  }
  subnet_id = aws_subnet.nexus.id
  vpc_security_group_ids = [ aws_security_group.nexus.id ]
}

resource "aws_key_pair" "key_pair" {
  key_name = var.key_name
  public_key = file(var.ssh_file)
}

#virtual network for the instances
resource "aws_vpc" "nexus" {
  cidr_block = var.vpc_cidr_block
  enable_dns_support = var.enable_dns_support
  tags = {
    Name = var.name_tag
  }
}

#subnet for the instances
resource "aws_subnet" "nexus" {
  vpc_id = aws_vpc.nexus.id
  cidr_block = var.subnet_cidr_block
  tags = {
    Name = var.name_tag
  }
}

#firewall configuration to expose ports
resource "aws_security_group" "nexus" {
  name = var.name_tag
  vpc_id = aws_vpc.nexus.id

  dynamic "ingress" {
    for_each = var.ingress_ports
    iterator = port 
    content {
      from_port = port.value
      to_port = port.value
      protocol = "tcp"
      cidr_blocks = [var.default_cidr_block]
    }
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [var.default_cidr_block]
  }

  tags = {
    Name = var.name_tag
  }
}

#used for connecting the machine to the internet
resource "aws_internet_gateway" "nexus" {
  vpc_id = aws_vpc.nexus.id
  tags = {
    Name = var.name_tag
  }
}

resource "aws_route_table" "nexus" {
  vpc_id = aws_vpc.nexus.id
  route {
    cidr_block = var.default_cidr_block
    gateway_id = aws_internet_gateway.nexus.id
  }
}

resource "aws_route_table_association" "nexus" {
  subnet_id = aws_subnet.nexus.id
  route_table_id = aws_route_table.nexus.id
}