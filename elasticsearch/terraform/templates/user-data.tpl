#!/bin/bash
set -e

# Ideally move all this to a proper config management tool
#
# Configure elasticsearch

cat <<'EOF' >/etc/elasticsearch/elasticsearch.yml
cluster.name: ${es_cluster_name}
#TODO: set node.name from hostname

# our init.d script sets the default to this as well
path.data: ${elasticsearch_data_dir}
path.logs: ${elasticsearch_log_dir}

bootstrap.mlockall: true
network.host: _ec2:privateIpv4_
discovery.type: ec2
discovery.zen.minimum_master_nodes: ${minimum_master_nodes}
discovery.ec2.groups: ${aws_security_group}
discovery.ec2.availability_zones: [${availability_zones}]

cloud.aws.region: ${aws_region}
repositories.url.allowed_urls: ["${es_allowed_urls}"]

gateway.recover_after_time: 5m
gateway.expected_nodes: ${expected_nodes}

## slowlog settings for the query part of a search
index.search.slowlog.threshold.query.warn: 5s
index.search.slowlog.threshold.query.info: 1s

## slowlog settings for the fetch part of a search
index.search.slowlog.threshold.fetch.warn: 5s

## index time slowlog settings
index.indexing.slowlog.threshold.index.info: 10s
EOF

# heap size
memory_in_bytes=`awk '/MemTotal/ {print $2}' /proc/meminfo`
heap_memory=$(( memory_in_bytes * ${elasticsearch_heap_memory_percent} / 100 / 1024 )) # take percentage of system memory, and convert to MB

# Make sure we're not over 31GB
max_memory=31000
if [[ "$heap_memory" -gt "$max_memory" ]]; then
        heap_memory="$max_memory"
fi

sudo sed -i 's/#MAX_LOCKED_MEMORY=unlimited/MAX_LOCKED_MEMORY=unlimited/' /etc/init.d/elasticsearch
sudo sed -i "s/#ES_HEAP_SIZE=.*$/ES_HEAP_SIZE=$${heap_memory}m/" /etc/default/elasticsearch

# data volume
data_volume_name="/dev/sdb"
sudo mkfs -t ext4 $data_volume_name
sudo mkdir -p ${elasticsearch_data_dir}
sudo mount $data_volume_name ${elasticsearch_data_dir}
sudo echo "$data_volume_name ${elasticsearch_data_dir} ext4 defaults,nofail 0 2" >> /etc/fstab
sudo chown -R elasticsearch:elasticsearch ${elasticsearch_data_dir}

# log volume
log_volume_name="/dev/sdc"
sudo mkfs -t ext4 $log_volume_name
sudo mkdir -p ${elasticsearch_log_dir}
sudo mount $log_volume_name ${elasticsearch_log_dir}
sudo echo "$log_volume_name ${elasticsearch_log_dir} ext4 defaults,nofail 0 2" >> /etc/fstab
sudo chown -R elasticsearch:elasticsearch ${elasticsearch_log_dir}

# Start Elasticsearch
sudo service elasticsearch start
