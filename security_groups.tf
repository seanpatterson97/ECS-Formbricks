########################################################################################################################
## SG for ECS Container Instances
########################################################################################################################

resource "aws_security_group" "ecs_container_instance" {
  name        = "Formbricks ECS Container"
  description = "Security group for ECS task running on Fargate"
  vpc_id      = aws_vpc.main.id
}

resource "aws_vpc_security_group_ingress_rule" "ecs_container_port" {
  security_group_id            = aws_security_group.ecs_container_instance.id
  from_port                    = var.container_port
  to_port                      = var.container_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.alb.id
  description                  = "Allow traffic from ALB only"
}

resource "aws_vpc_security_group_egress_rule" "ecs_all_egress" {
  security_group_id = aws_security_group.ecs_container_instance.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow all egress"
}

########################################################################################################################
## SG for ALB
########################################################################################################################

resource "aws_security_group" "alb" {
  name        = "Formbricks ALB"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.main.id
}

resource "aws_vpc_security_group_egress_rule" "alb_all_egress" {
  security_group_id = aws_security_group.alb.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow all egress"
}

# Allow HTTP traffic from CloudFront via VPC Origin
# Even with VPC Origins, the ALB sees CloudFront edge IPs as the source.
# AWS recommends using the managed prefix list or the CloudFront-VPCOrigins-Service-SG.
# https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-vpc-origins.html

data "aws_ec2_managed_prefix_list" "cloudfront" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

resource "aws_vpc_security_group_ingress_rule" "alb_cloudfront_http_ingress" {
  security_group_id = aws_security_group.alb.id
  from_port         = 80
  ip_protocol       = "tcp"
  prefix_list_id    = data.aws_ec2_managed_prefix_list.cloudfront.id
  to_port           = 80
  description       = "Allow HTTP from CloudFront (VPC Origin)"
}

########################################################################################################################
## SG for RDS instance
########################################################################################################################

resource "aws_security_group" "rds" {
  name        = "Formbricks RDS"
  description = "Security group for RDS database"
  vpc_id      = aws_vpc.main.id
}

resource "aws_vpc_security_group_ingress_rule" "rds_ingress" {
  security_group_id            = aws_security_group.rds.id
  from_port                    = var.db_port
  to_port                      = var.db_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.ecs_container_instance.id
  description                  = "Allow traffic from ECS containers only"
}

########################################################################################################################
## SG for Elasticache
########################################################################################################################

resource "aws_security_group" "elasticache" {
  name        = "Formbricks elasticache"
  description = "security group for elasticache"
  vpc_id      = aws_vpc.main.id
}

resource "aws_vpc_security_group_ingress_rule" "elasticache_ingress" {
  security_group_id            = aws_security_group.elasticache.id
  from_port                    = 6379
  to_port                      = 6379
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.ecs_container_instance.id
  description                  = "Allow traffic from ECS containers only"
}