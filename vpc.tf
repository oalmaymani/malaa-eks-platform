module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.vpc_name
  cidr = local.vpc_cidr

  azs = local.azs

  public_subnets   = local.public_subnets
  private_subnets  = local.private_subnets
  database_subnets = local.database_subnets

  public_subnet_names   = local.public_subnet_names
  private_subnet_names  = local.private_subnet_names
  database_subnet_names = local.database_subnet_names

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = local.tags
}

