#!/bin/bash
# Copyright (c) HashiCorp, Inc.

# Install jq
apt-get update
apt-get -y install jq unzip

secretUri=$(curl -sS "http://metadata.google.internal/computeMetadata/v1/instance/attributes/secret-id" -H "Metadata-Flavor: Google")
# Secrets URI is of the form projects/$PROJECT_NUMBER/secrets/$SECRET_NAME/versions/$SECRET_VERSION
# Split into array based on `/` delimeter
IFS="/" read -r -a secretsConfig <<<"$secretUri"

# Get SECRET_NAME and SECRET_VERSION
SECRET_NAME=${secretsConfig[3]}
SECRET_VERSION=${secretsConfig[5]}

# Access secret from secrets manager
secrets=$(gcloud secrets versions access "$SECRET_VERSION" --secret="$SECRET_NAME")

# Set secrets as env vars
# shellcheck disable=SC2046

# Use wordsplitting
export $(echo "$secrets" | jq -r "to_entries|map(\"\(.key)=\(.value|tostring)\")|.[]")

# Start agent service
cd /agent || exit
./tfc-agent
