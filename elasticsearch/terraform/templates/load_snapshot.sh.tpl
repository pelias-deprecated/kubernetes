#!/bin/bash
set -euo pipefail


# set variables, convert terraform variables to variables used by this shell script
cluster_url="http://localhost:9200"
es_repo_name="initial_snapshot"
s3_bucket="${snapshot_s3_bucket}"
base_path="${snapshot_base_path}"
snapshot_name="${snapshot_name}"
read_only="${snapshot_repository_read_only}"
alias_name="${snapshot_alias_name}"
replica_count="${snapshot_replica_count}"

# check all required variables are set
if [[ "$snapshot_name" == "" ]]; then
  echo "snapshot_name not set, no snapshot will be loaded"
  exit 0
fi

if [[ "$s3_bucket" == "" ]]; then
  echo "s3_bucket not set, no snapshot will be loaded"
  exit 0
fi

## 0. wait for elasticsearch to become ready
function elastic_status(){
  curl --output /dev/null --silent --write-out "%{http_code}" "$cluster_url" || true;
}

echo "waiting for elasticsearch on $cluster_url"
until test $(elastic_status) -eq 200; do
  printf '.'
  sleep 2
done

# check if this node is the master node
cluster_url="http://localhost:9200"

if $(curl -s "$cluster_url/_cat/master" | grep -q `hostname`); then
  echo "this is the master node, loading snapshot"
else
  echo "this is not the master, aborting snapshot load"
  exit 0
fi

## 1. set proper settings
echo "setting optimal index recovery settings for higher performance on $cluster_url"
curl -XPUT "$cluster_url/_cluster/settings" -d '{
  "persistent": {
    "indices.recovery.max_bytes_per_sec": "4000mb",
      "cluster.routing.allocation.node_concurrent_recoveries": 24,
      "cluster.routing.allocation.node_initial_primaries_recoveries": 24
  }
}'
echo

## 2. create snapshot repository
curl -s -XPOST "$cluster_url/_snapshot/$es_repo_name" -d "{
  \"type\": \"s3\",
    \"settings\": {
      \"bucket\": \"$s3_bucket\",
      \"readonly\": $read_only,
      \"base_path\" : \"$base_path\",
      \"max_snapshot_bytes_per_sec\" : \"1000mb\",
      \"max_restore_bytes_per_sec\" : \"1000mb\"
    }
}"
echo

## 3. import snapshot
curl -s -XPOST "$cluster_url/_snapshot/$es_repo_name/$snapshot_name/_restore" -d "{
  \"indices\": \"pelias\",
    \"rename_pattern\": \"pelias\",
    \"rename_replacement\": \"$snapshot_name\"
}"

## 4. make alias if alias_name set

if [[ "$alias_name" != "" ]]; then
  echo "creating $alias_name alias pointing to $snapshot_name on $cluster_url"

  curl -s -XPOST "$cluster_url/_aliases" -d "{
    \"actions\": [{
      \"add\": {
        \"index\": \"$snapshot_name\",
        \"alias\": \"$alias_name\"
      }
    }]
  }"
  echo
else
  echo "no alias_name set, will not create alias"
fi

## 5. set replica count
echo "setting replica count to $replica_count on $snapshot_name index in $cluster_url"

curl -s -XPUT "$cluster_url/$snapshot_name/_settings" -d "{
  \"index\" : {
    \"number_of_replicas\" : $replica_count
  }
}"

## 6. make cluster read_only (prevents deletion of indices)
curl -s -XPUT "$cluster_url/_cluster/settings" -d '{
  "persistent" : {
    "cluster.blocks.read_only" : true
  }
}'
echo
