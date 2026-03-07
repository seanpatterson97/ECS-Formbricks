########################################################################################################################
## Create VPC 
########################################################################################################################

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project}_VPC_${var.environment}"
  }
}

########################################################################################################################
## S3 Gateway Endpoint — keeps S3 traffic on the AWS private network instead of routing through NAT
########################################################################################################################

resource "aws_vpc_endpoint" "s3" {
  vpc_id          = aws_vpc.main.id
  service_name    = "com.amazonaws.${var.region}.s3"
  route_table_ids = aws_route_table.private[*].id

  tags = {
    Name = "${var.project}_S3_Endpoint_${var.environment}"
  }
}

########################################################################################################################
## Create Internet Gateway for egress/ingress connections to resources in the public subnets
########################################################################################################################

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project}_InternetGateway_${var.environment}"
  }
}