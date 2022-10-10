#!/bin/bash

mkdir creds
ssh-keygen -t rsa -C "$HOSTNAME" -f "./creds/gcloud_instance" -P ""
