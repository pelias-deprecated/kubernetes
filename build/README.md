# Pelias Build on Kubernetes

This is an _experimental_ project for running a Pelias build on Kubernetes.

It should work, but hasn't been updated much in a long time.

However, you probably shouldn't use it, as it hasn't been maintained in some time. Instead, use the [Pelias Docker setup](http://github.com/pelias/docker/) to run a build, and save the Elasticsearch index and other data in locations where they can be used by your primary Pelias installation.

## Requirements

Each importer has different memory requirements. Note that they all require the PIP service (6GB+ RAM) to be running first.

* Who's on First (requires about 1GB of RAM)
* OpenStreetMap (requires between 0.25GB and 6GB of RAM depending on import size)
* OpenAddresses (requires 1GB of RAM)
* Geonames (requires ~0.5GB of RAM)
* Polylines (requires 1GB of RAM)

Use the [data sources](https://github.com/pelias/documentation/blob/master/data-sources.md) documentation to decide
which importers to be run.

Importers can be run in any order, in parallel or one at a time.

## Running a build

You can "install" the chart to run a build like so:

```
helm install --name pelias-build --namespace pelias ./path/to/pelias/build/chart -f path/to/pelias-values.yaml
```

`values.yaml` can be reused between the two charts, however, the Pelias services chart must be up and running first.
