########################################################################################################################
## This resource returns a list of all AZ available in the region configured in the AWS credentials
########################################################################################################################

data "aws_availability_zones" "available" {}

########################################################################################################################
## Public Subnets (one public subnet per AZ)
########################################################################################################################

resource "aws_subnet" "public" {
  count                   = var.az_count
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 8, var.az_count + count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true

  tags = {
    Name     = "${var.project}_PublicSubnet_${count.index}_${var.environment}"
  }
}

########################################################################################################################
## Route Table with egress route to the internet
########################################################################################################################

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name     = "${var.project}_PublicRouteTable_${var.environment}"
  }
}

########################################################################################################################
## Associate Route Table with Public Subnets
########################################################################################################################

resource "aws_route_table_association" "public" {
  count          = var.az_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

########################################################################################################################
## Make our Route Table the main Route Table
########################################################################################################################

resource "aws_main_route_table_association" "public_main" {
  vpc_id         = aws_vpc.main.id
  route_table_id = aws_route_table.public.id
}

########################################################################################################################
## Creates one Elastic IP per AZ (one for each NAT Gateway in each AZ)
########################################################################################################################

resource "aws_eip" "nat_gateway" {
  count  = var.az_count
  domain = "vpc"

  tags = {
    Name     = "${var.project}_EIP_${count.index}_${var.environment}"
  }
}

########################################################################################################################
## Creates one NAT Gateway per AZ
########################################################################################################################

resource "aws_nat_gateway" "nat_gateway" {
  count         = var.az_count
  subnet_id     = aws_subnet.public[count.index].id
  allocation_id = aws_eip.nat_gateway[count.index].id

  tags = {
    Name     = "${var.project}_NATGateway_${count.index}_${var.environment}"
  }
}

########################################################################################################################
## One private subnet per AZ
########################################################################################################################

resource "aws_subnet" "private" {
  count             = var.az_count
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = aws_vpc.main.id

  tags = {
    Name     = "${var.project}_PrivateSubnet_${count.index}_${var.environment}"
  }
}

########################################################################################################################
## Route to the internet using the NAT Gateway
########################################################################################################################

resource "aws_route_table" "private" {
  count  = var.az_count
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway[count.index].id
  }

  tags = {
    Name     = "${var.project}_PrivateRouteTable_${count.index}_${var.environment}"
  }
}

########################################################################################################################
## Associate Route Table with Private Subnets
########################################################################################################################

resource "aws_route_table_association" "private" {
  count          = var.az_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}