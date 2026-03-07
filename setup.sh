#!/usr/bin/env bash

# -e: Exits if any command fails, -u: Treats unset variables as errors

set -eu

# Copy the example tfvars and prompt for mandatory variables

if [ -f terraform.auto.tfvars ]; then
  echo "terraform.auto.tfvars already exists. Remove it first to re-run setup."
  exit 1
fi

cp terraform.auto.tfvars.example terraform.auto.tfvars

read -p "Enter domain name (e.g. demo.yoursite.com): " domain
sed -i "s|^domain_name = \"\".*|domain_name = \"$domain\"|" terraform.auto.tfvars

read -p "Enter AWS region (e.g. us-east-1): " region
sed -i "s|^region = \"\".*|region = \"$region\"|" terraform.auto.tfvars

read -p "Enter the Route53 zone ID of your top-level domain: " zone
sed -i "s|^tld_zone_id = \"\".*|tld_zone_id = \"$zone\"|" terraform.auto.tfvars

echo ""
echo "terraform.auto.tfvars created. Review it, then run: terraform init && terraform plan"