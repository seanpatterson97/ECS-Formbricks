# Formbricks on AWS ECS Fargate

A production-ready Terraform deployment of [Formbricks](https://formbricks.com) on AWS ECS Fargate, designed around scalability and high availability.

This project builds on the foundation of my earlier [moodle-on-aws](https://github.com/seanpatterson97/moodle-on-aws) project, applying lessons learned to a fresh deployment with a new application and several architectural improvements including:
  * **CloudFront VPC Origin** — The ALB is deployed internally with no public IP. CloudFront connects to it via a VPC Origin, eliminating the need for custom headers or public-facing load balancers and reducing the attack surface.
  * **Least privilege security groups** — Security group chaining ensures each tier (CloudFront → ALB → ECS → RDS/Elasticache) only accepts traffic from the tier directly above it.
  * **Secrets management** — RDS credentials are managed by AWS Secrets Manager with no plaintext passwords in Terraform state. A bridge secret constructs the full connection string and injects it into ECS tasks at runtime.
  * **S3 Gateway Endpoint** — S3 traffic stays on the AWS private network, bypassing NAT Gateway costs and latency.
  * **Automated setup** — A setup script prompts for mandatory variables and generates the tfvars file to assist in launching the project.

## Architecture

![Cloud Architecture](/assets/topology.png)

ECS Fargate tasks run in private subnets across 2 or more availability zones, scaling via Application Auto Scaling target tracking policies (CPU and memory). Each private subnet has access to the following backend services:

  * A serverless Valkey cache for session management and caching
  * RDS PostgreSQL (Multi-AZ)
  * S3 for user-uploaded files (via Gateway Endpoint)

Users connect through CloudFront, which routes traffic to an internal ALB via a VPC Origin. The ALB forwards requests to ECS tasks over HTTP.

For Formbricks configurations that require internet access (third-party integrations, webhooks), egress is provided by NAT Gateways deployed in public subnets for each AZ.

CloudWatch Log Groups aggregate container logs, and AWS Certificate Manager (ACM) with Route 53 handle SSL for the configured subdomain.

## Getting Started

> **Note:** This project uses minimal compute and storage settings for demonstration purposes. You will incur a small cost while the infrastructure is running. Run `terraform destroy` when finished to avoid unnecessary charges.

### Prerequisites

  * Terraform
  * AWS credentials configured (via AWS CLI, environment variables, or IAM role)
  * A top-level domain hosted in Route 53 (the project deploys to a configurable subdomain)

### Setup

Clone the repo and navigate to it:

```
git clone https://github.com/seanpatterson97/ECS-Formbricks.git && cd ECS-Formbricks
```

If using Terraform Cloud for remote state, uncomment and configure the `cloud` block in [providers.tf](providers.tf).

Run the setup script, which will prompt for mandatory variables and generate your `terraform.auto.tfvars` file:

```
sh setup.sh
```

Initialize, plan, and apply:

```
terraform init
terraform plan
```

After you are satisfied with the plan:

```
terraform apply
```

Full deployment takes approximately 10–15 minutes. After the apply completes, the application may still be initializing PostgreSQL. It can take an additional 5 minutes for health checks to begin passing.

Once the ALB reports healthy targets, the Formbricks setup page will be available at your configured domain.

![Formbricks Welcome](/assets/formbricks_welcome.png)

### Acknowledgments
  * [Aws-scenario-ecs-fargate](https://github.com/nexgeneerz/aws-scenario-ecs-fargate) This project contains a fantastic [blog post](https://www.gyden.io/en/content-hub/how-to-setup-amazon-ecs-fargate-using-terraform) which details the basics of a modern production-ready solution on fargate. I used it's configuration as a starting point for the project.