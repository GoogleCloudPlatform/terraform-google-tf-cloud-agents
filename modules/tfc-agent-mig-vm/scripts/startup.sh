#!/bin/bash
# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
curl -o agent.zip --location https://releases.hashicorp.com/tfc-agent/"${AGENT_VERSION}"/tfc-agent_"${AGENT_VERSION}"_linux_amd64.zip

# Download the signature files.
curl -Os https://releases.hashicorp.com/tfc-agent/"${AGENT_VERSION}"/tfc-agent_"${AGENT_VERSION}"_SHA256SUMS
curl -Os https://releases.hashicorp.com/tfc-agent/"${AGENT_VERSION}"/tfc-agent_"${AGENT_VERSION}"_SHA256SUMS.sig

# Import the public key as referenced above, or available in full below.
curl -o hashicorp.asc https://www.hashicorp.com/.well-known/pgp-key.txt
gpg --import hashicorp.asc

# Verify the signature file is untampered.
gpg --verify tfc-agent_"${AGENT_VERSION}"_SHA256SUMS.sig tfc-agent_"${AGENT_VERSION}"_SHA256SUMS

# Verify the SHASUM matches the archive.
shasum -a 256 -c tfc-agent_"${AGENT_VERSION}"_SHA256SUMS

mkdir /agent
unzip agent.zip -d /agent
rm tfc-agent_"${AGENT_VERSION}"_SHA256SUMS
rm tfc-agent_"${AGENT_VERSION}"_SHA256SUMS.sig
rm -f agent.zip

# Start agent service
cd /agent || exit
./tfc-agent
