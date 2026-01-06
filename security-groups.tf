resource "aws_security_group" "dmz_sg" {
  name        = "dmz-sg-tf"
  description = "DMZ Security Group"
  vpc_id      = module.vpc.vpc_id

  # Ingress
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress
  egress {
    description = "All TCP outbound"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name = "dmz-sg-tf"
  })
}

#################################
# Servers Security Group
#################################
resource "aws_security_group" "servers_sg" {
  name        = "servers-sg-tf"
  description = "Servers Security Group"
  vpc_id      = module.vpc.vpc_id

  # Ingress
  ingress {
    description = "HTTPS from DMZ subnet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.16.0/20"]
  }

  ingress {
    description = "HTTP from DMZ subnet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.16.0/20"]
  }

  # Egress
  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name = "servers-sg-tf"
  })
}

#################################
# Database Security Group
#################################
resource "aws_security_group" "database_sg" {
  name        = "database-sg-tf"
  description = "Database Security Group"
  vpc_id      = module.vpc.vpc_id

  # Ingress
  ingress {
    description = "Port 8080 from Servers subnet"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.0.32.0/20"]
  }

  ingress {
    description = "Port 26257 from Servers subnet"
    from_port   = 26257
    to_port     = 26257
    protocol    = "tcp"
    cidr_blocks = ["10.0.32.0/20"]
  }

  # Egress
  egress {
    description = "Port 8080 to Servers subnet"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.0.32.0/20"]
  }

  egress {
    description = "Port 26257 to Servers subnet"
    from_port   = 26257
    to_port     = 26257
    protocol    = "tcp"
    cidr_blocks = ["10.0.32.0/20"]
  }

  tags = merge(local.tags, {
    Name = "database-sg-tf"
  })
}
