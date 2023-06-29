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

# Get agent archive
curl -o agent.zip --location "https://releases.hashicorp.com/tfc-agent/${AGENT_VERSION}/tfc-agent_${AGENT_VERSION}_linux_amd64.zip"

# Download the signature files.
curl -Os https://releases.hashicorp.com/tfc-agent/${AGENT_VERSION}/tfc-agent_${AGENT_VERSION}_SHA256SUMS
curl -Os https://releases.hashicorp.com/tfc-agent/${AGENT_VERSION}/tfc-agent_${AGENT_VERSION}_SHA256SUMS.sig

# Import the public key as referenced above, or available in full below.
curl -o hashicorp.asc https://www.hashicorp.com/.well-known/pgp-key.txt
gpg --import hashicorp.asc

# Verify the signature file is untampered.
gpg --verify tfc-agent_${AGENT_VERSION}_SHA256SUMS.sig tfc-agent_${AGENT_VERSION}_SHA256SUMS

# Verify the SHASUM matches the archive.
shasum -a 256 -c tfc-agent_${AGENT_VERSION}_SHA256SUMS

mkdir /agent
unzip agent.zip -d /agent
rm tfc-agent_${AGENT_VERSION}_SHA256SUMS
rm tfc-agent_${AGENT_VERSION}_SHA256SUMS.sig
rm -f agent.zip

# Start agent service
cd /agent || exit
./tfc-agent
