### VPC

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"

  name = "${var.cluster_name}-eks-vpc"

  cidr = var.vpc_subnet_cidr

  azs              = var.availability_zones
  private_subnets  = var.private_subnet_cidr
  public_subnets   = var.public_subnet_cidr
  database_subnets = var.db_subnet_cidr

  create_database_subnet_group = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway = true

  tags = {
    Name                                        = "${var.cluster_name}-vpc"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    Name                                        = "${var.cluster_name}-eks-public"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = 1
  }
  private_subnet_tags = {
    Name                                        = "${var.cluster_name}-eks-private"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = 1
  }
  database_subnet_tags = {
    Name = "${var.cluster_name}-eks-db"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = module.vpc.private_route_table_ids

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "*",
      "Resource": ["arn:aws:s3:::*"]
    }
  ]
}
POLICY

  tags = {
    Name = "${var.cluster_name}-s3-vpc-endpoint"
  }
}
