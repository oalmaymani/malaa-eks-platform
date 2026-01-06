locals {
  vpc_name = "malaa-vpc-tf"
  vpc_cidr = "10.0.0.0/16"

  azs = ["eu-north-1a", "eu-north-1b"]

  # Subnet names (WITH -tf)
  public_subnet_names = ["public_subnet-1-tf", "public_subnet-2-tf"]

  private_subnet_names = [
    "private_DMZ_subnet-tf",
    "private_servers_subnet-tf",
    "private-server-subnet-2-tf",
  ]

  database_subnet_names = ["Private_database_subnet-1-tf", "Private_database_subnet-2-tf"]


  public_subnets   = ["10.0.0.0/20", "10.0.128.0/20"]
  private_subnets  = ["10.0.16.0/20", "10.0.32.0/20", "10.0.64.0/20"]
  database_subnets = ["10.0.48.0/20", "10.0.80.0/20"]


  tags = {
    Terraform = "true"
  }
}
