#!/bin/bash -ex

#This script will set up Pelias on Kubernetse from scratch
# it doesn't yet handle updating an existing config

#namespace
kubectl create -f namespace.yaml

#configuration
kubectl create --namespace=pelias-dev -f pelias-json-configmap.yaml

# service accounts
kubectl create --namespace=pelias-dev -f elasticsearch-serviceaccount.yaml

# elasticsearch
kubectl create --namespace=pelias-dev -f elasticsearch-service.yaml
kubectl create --namespace=pelias-dev -f elasticsearch-replicationcontroller.yaml

# api
kubectl create --namespace=pelias-dev -f pelias-api.yaml

# set up schema (just runs a job)
kubectl create --namespace=pelias-dev -f schema-create-job.yaml

# run importers
