#!/bin/bash

terraform destroy --auto-approve

echo <<EOF
terraform {
  required_version = ">= 1.2.0"
}
EOF > ./infrastructure/backend.tf

rm -rf ./creds