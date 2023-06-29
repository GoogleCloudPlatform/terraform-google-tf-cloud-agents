# Copyright (c) HashiCorp, Inc.

FROM hashicorp/tfc-agent

USER root

# Downloading gcloud package
RUN curl https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz > /tmp/google-cloud-sdk.tar.gz

# Installing the package
RUN mkdir -p /usr/local/gcloud \
  && tar -C /usr/local/gcloud -xvf /tmp/google-cloud-sdk.tar.gz \
  && /usr/local/gcloud/google-cloud-sdk/install.sh

# Adding the package path to local
ENV PATH $PATH:/usr/local/gcloud/google-cloud-sdk/bin

# /home/tfc-agent/bin/tfc-agent is the entrypoint from the hashicorp image
ENTRYPOINT ["/home/tfc-agent/bin/tfc-agent"]
CMD ["-single"]
