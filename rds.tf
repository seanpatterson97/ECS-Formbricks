############################################
## Create RDS instance
############################################

resource "aws_db_instance" "formbricks" {
  allocated_storage           = var.db_allocated_storage
  max_allocated_storage       = var.db_max_allocated_storage
  manage_master_user_password = true

  db_name                = var.db_name
  engine                 = var.db_engine
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  username               = var.db_username
  skip_final_snapshot    = true # required to destroy
  deletion_protection    = var.db_deletion_protection
  db_subnet_group_name   = aws_db_subnet_group.private_subnets.name
  multi_az               = true
  port                   = var.db_port
  vpc_security_group_ids = [aws_security_group.rds.id]
}

resource "aws_db_subnet_group" "private_subnets" {
  name       = "private_subnets"
  subnet_ids = aws_subnet.private[*].id # gather all private subnets
}
