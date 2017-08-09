#!/bin/bash -ex

#This script will set up Pelias on Kubernetse from scratch
# it doesn't yet handle updating an existing config
CMD=${1:-'create'}
NAMESPACE=${2:-'pelias-dev'}

# create namespace
# kubectl ${CMD} -f namespace.yaml

# use namespace for all subsequent requests
kubectl config set-context $(kubectl config current-context) --namespace=${NAMESPACE}

# configuration
kubectl ${CMD} -f pelias-json-configmap.yaml

# service accounts
kubectl ${CMD} -f elasticsearch-serviceaccount.yaml

# elasticsearch
kubectl ${CMD} -f elasticsearch-service.yaml
kubectl ${CMD} -f elasticsearch-replicationcontroller.yaml

# api
kubectl ${CMD} -f pelias-api.yaml

# pip service
kubectl ${CMD} -f pelias-pip-service.yaml

# placeholder
kubectl ${CMD} -f pelias-placeholder-service.yaml

# set up schema (just runs a job)
kubectl ${CMD} -f schema-create-job.yaml

# run importers
kubectl ${CMD} -f openaddresses-import-job.yaml

# run importers
kubectl ${CMD} -f openstreetmap-import-job.yaml

# open dashboard in your browser
# minikube dashboard

# find api service IP address
# minikube service --url pelias-api-service
