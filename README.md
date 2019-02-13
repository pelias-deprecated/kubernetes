# Pelias Kubernetes Configuration

This repository contains Kubernetes configuration files to create a production ready instance of Pelias.

We use [Helm](https://helm.sh/) to manage Pelias installation.

This configuration is meant to be run on Kubernetes using real hardware or full sized virtual
machines in the cloud. It could work on a personal computer with
[minikube](https://github.com/kubernetes/minikube), but larger installations will likely benefit from additional RAM.

## Setup

First, set up a Kubernetes cluster however works best for you. A popular choice is to use
[kops](https://github.com/kubernetes/kops) on AWS. The [Getting Started on AWS Guide](https://github.com/kubernetes/kops/blob/master/docs/aws.md) is a good starting point.

### Helm Installation

Helm must be installed before continuing. See [https://github.com/helm/helm#install](https://github.com/helm/helm#install) for instructions.

### Sizing the Kubernetes cluster

A working Pelias cluster contains at least some of the following services:
* Pelias API (requires about 50MB of RAM)
* Libpostal Service (requires about 2GB of RAM)
* Placeholder Service (Requires 256MB of RAM)
* Point in Polygon (PIP) Service (Requires up to 6GB of RAM for a full planet build) (**required for reverse geocoding**)
* Interpolation Service (requires ~2GB of RAM)

See the [Pelias Services](https://github.com/pelias/documentation/blob/master/services.md) documentation to determine which services to run.

Some of the following importers will additionally have to be run to initially populate data
* Who's on First (requires about 1GB of RAM)
* OpenStreetMap (requires between 0.25GB and 6GB of RAM depending on import size)
* OpenAddresses (requires 1GB of RAM)
* Geonames (requires ~0.5GB of RAM)
* Polylines (requires 1GB of RAM)

Finally, the importers require the PIP service to be running

Use the [data sources](https://mapzen.com/documentation/search/data-sources/) documentation to decide
which importers to be run.

Importers can be run in any order, in parallel or one at a time.

This means around 10GB of RAM is required to bring up all the services, and up to another 15GB of RAM is needed to
run all the importers at once. 2 instances with 8GB of RAM each is a good starting point just for
the services.

If using kops, it defaults to `t2.small` instances, which are far too small (they only have 2GB of ram).

You can edit the instance types using `kops edit ig nodes` before starting your cluster. `m4.large` is a good choice to start.

### Pelias Helm Chart installation

It's recommended to use a `.yaml` file to configure the Pelias chart. See [values.yaml](https://github.com/pelias/kubernetes/blob/master/values.yaml) for a starting point.

The pelias helm chart can be installed as follows:

```
helm install --name pelias --namespace pelias ./path/to/pelias/charts -f path/to/pelias-values.yaml
```

### Running a build

The `build` directory in this repository contains an additional chart for running a Pelias build. It can be run in a similar way to the Pelias services chart:

```
helm install --name pelias-build --namespace pelias ./path/to/pelias/build/chart -f path/to/pelias-values.yaml
```

`values.yaml` can be reused between the two charts, however, the Pelias services chart must be up and running first.

## Elasticsearch

Elasticsearch is used as the primary datastore for Pelias data. As a powerful database with built in
scalability and replication abilities, it is not currently well suited for running in Kubernetes.

Instead, it's preferable to create "regular" instances in your cloud provider or on your own
hardware. To help with this, the `elasticsearch/` directory in this repository contains tools for
setting up a production ready, Pelias compatible Elasticsearch cluster. It uses
[Terraform](http://terraform.io/) and [Packer](http://packer.io/) to do this. See the directory
[README](./elasticsearch/README.md) for more details.

## Handy Kubernetes commands

We find ourselves using these from time to time.

### debugging 'init containers'

Sometimes an 'init container' fails to start, you can view the init logs:

```bash
# kubectl logs {{pod_name}} -c {{init_container_name}}
kubectl logs geonames-import-4vgq3 -c geonames-download
```

### opening a bash prompt in a running container

It can be useful to open a shell inside a running container for debugging:

```bash
# kubectl exec -it {{pod_name}} -- {{command}}
kubectl exec -it pelias-pip-3625698757-dtzmd -- /bin/bash
```
