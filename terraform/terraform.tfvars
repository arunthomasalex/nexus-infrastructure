props = {
  region    = "ap-south-1"
  ami       = "ami-068257025f72f470d"
  type      = "t3.medium"
  enable_ip = true
  name      = "nexus"
}
availability_zone = "ap-south-1c"
enable_dns_support = true
env                = "dev"
key_name           = "nexus"
ssh_file           = "../config/sshkey.pub"
user_script        = ""
vpc_cidr_block     = "10.0.0.0/16"
subnet_cidr_block  = "10.0.1.0/24"
default_cidr_block = "0.0.0.0/0"
name_tag           = "nexus"
ingress_ports      = [22, 80, 443]
