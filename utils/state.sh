#!/bin/bash

echo <<EOF
terraform {
  required_version = ">= 1.2.0"
  backend "gcs" {
   bucket  = "BUCKET_NAME"
   prefix  = "terraform/state"
 }
}
EOF > ./infrastructure/backend.tf