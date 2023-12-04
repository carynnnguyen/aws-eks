
resource "aws_key_pair" "deployer" {
  key_name   = var.cluster_name
  public_key = var.ec2_key_public_key
}
