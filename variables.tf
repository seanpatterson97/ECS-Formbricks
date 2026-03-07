########################################################################################################################
## Service variables
########################################################################################################################

variable "project" {
  description = "Project name used in resource names and tags"
  default     = "formbricks"
  type        = string
}

variable "domain_name" {
  description = "Domain name of the service (like service.example.com)"
  type        = string
}

variable "service_name" {
  description = "A Docker image-compatible name for the service"
  default     = "formbricks"
  type        = string
}

variable "environment" {
  description = "Environment for deployment (like dev or staging)"
  default     = "dev"
  type        = string
}

########################################################################################################################
## AWS credentials
########################################################################################################################

variable "region" {
  description = "AWS region"
  default     = "us-east-1"
  type        = string
}

########################################################################################################################
## Network variables
########################################################################################################################

variable "tld_zone_id" {
  description = "Top level domain hosted zone ID"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC network"
  default     = "10.1.0.0/16"
  type        = string
}

variable "az_count" {
  description = "Describes how many availability zones are used"
  default     = 2
  type        = number
}

########################################################################################################################
## ECS variables
########################################################################################################################

variable "ecs_task_desired_count" {
  description = "How many ECS tasks should run in parallel"
  default     = 2
  type        = number
}

variable "ecs_task_min_count" {
  description = "How many ECS tasks should minimally run in parallel"
  default     = 2
  type        = number
}

variable "ecs_task_max_count" {
  description = "How many ECS tasks should maximally run in parallel"
  default     = 10
  type        = number
}

variable "ecs_task_deployment_minimum_healthy_percent" {
  description = "How many percent of a service must be running to still execute a safe deployment"
  default     = 50
  type        = number
}

variable "ecs_task_deployment_maximum_percent" {
  description = "How many additional tasks are allowed to run (in percent) while a deployment is executed"
  default     = 100
  type        = number
}

variable "cpu_target_tracking_desired_value" {
  description = "Target tracking for CPU usage in %"
  default     = 70
  type        = number
}

variable "memory_target_tracking_desired_value" {
  description = "Target tracking for memory usage in %"
  default     = 80
  type        = number
}

variable "container_port" {
  description = "Port of the container"
  type        = number
  default     = 3000
}

variable "cpu_units" {
  description = "Amount of CPU units for a single ECS task"
  default     = 1024
  type        = number
}

variable "memory" {
  description = "Amount of memory in MB for a single ECS task"
  default     = 2048
  type        = number
}

########################################################################################################################
## Cloudwatch
########################################################################################################################

variable "retention_in_days" {
  description = "Retention period for Cloudwatch logs"
  default     = 7
  type        = number
}

########################################################################################################################
## ALB
########################################################################################################################

variable "healthcheck_endpoint" {
  description = "Endpoint for ALB healthcheck"
  type        = string
  default     = "/"
}

variable "healthcheck_matcher" {
  description = "HTTP status code matcher for healthcheck"
  type        = string
  default     = "200"
}

########################################################################################################################
## RDS variables
########################################################################################################################

variable "db_name" {
  description = "Name of the database"
  type        = string
  default     = "application_database"
}

variable "db_engine" {
  description = "What type of database to utilize"
  type        = string
  default     = "postgres"
}

variable "db_engine_version" {
  description = "Version of the database engine"
  type        = string
  default     = "18.1"
}

variable "db_username" {
  description = "Username for the database"
  type        = string
  default     = "postgres"
}

variable "db_allocated_storage" {
  description = "Amount of storage allocated for the database"
  type        = number
  default     = 10
}

variable "db_max_allocated_storage" {
  description = "Maximum amount of storage allocated for the database"
  type        = number
  default     = 20
}

variable "db_deletion_protection" {
  description = "Prevents the database from being deleted"
  type        = bool
  default     = false
}

variable "db_instance_class" {
  description = "Instance class for the database"
  type        = string
  default     = "db.t3.micro"
}

variable "db_port" {
  description = "Port for the database"
  type        = number
  default     = 5432
}


########################################################################################################################
## S3 variables
########################################################################################################################

variable "bucket_name" {
  description = "name of bucket for uploaded content from users"
  type        = string
  default     = "formbricks"
}