#!/usr/bin/env bash

if [[ -z ${INSTANA_APPLICATION_KEY} ]]; then
  echo "Please provide environment variable INSTANA_APPLICATION_KEY"
  exit 1
fi

# Set variables
SEALED_SECRET_NAMESPACE=${SEALED_SECRET_NAMESPACE:-sealed-secrets}
SEALED_SECRET_CONTOLLER_NAME=${SEALED_SECRET_CONTOLLER_NAME:-sealed-secrets}

# Create Kubernetes Secret yaml
oc create secret generic instana-agent \
--from-literal=key=${INSTANA_APPLICATION_KEY} \
--dry-run=client -o yaml > delete-instana-agent-secret.yaml

# Encrypt the secret using kubeseal and private key from the cluster
kubeseal -n instana-agent --controller-name=${SEALED_SECRET_CONTOLLER_NAME} --controller-namespace=${SEALED_SECRET_NAMESPACE} -o yaml < delete-instana-agent-secret.yaml > instana-agent-secret.yaml

# NOTE, do not check delete-mq-client-jks-password-secret.yaml into git!
rm delete-instana-agent-secret.yaml
