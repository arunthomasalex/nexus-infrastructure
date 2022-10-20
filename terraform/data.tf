data "aws_ebs_volume" "nexus" {
  most_recent = true
  tags = {
    Name = var.name_tag
  }
}