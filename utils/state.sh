#!/bin/bash

echo -e "terraform {\n/trequired_version = \">= 1.2.0\"/n/tbackend \"gcs\" {\n\t\tbucket  = \"BUCKET_NAME\"/n/t/tprefix  = \"terraform/state\"/n/t}/n}" > ./infrastructure/backend.tf