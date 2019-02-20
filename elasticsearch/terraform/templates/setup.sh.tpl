#!/bin/bash
set -e

# Ideally move all this to a proper config management tool
#
# Configure elasticsearch

cat <<'EOF' >/etc/elasticsearch/elasticsearch.yml
cluster.name: ${es_cluster_name}
node.name: $${HOSTNAME} # the $${HOSTNAME} var is filled in by Elasticsearch

# our init.d script sets the default to this as well
path.data: ${elasticsearch_data_dir}
path.logs: ${elasticsearch_log_dir}

# enable memory locking
bootstrap.memory_lock: true

network.host: [ '_ec2:privateIpv4_', _local_ ]
network.publish_host: '_ec2:privateIpv4_'
discovery.type: ec2
discovery.zen.minimum_master_nodes: ${minimum_master_nodes}
discovery.ec2.groups: ${aws_security_group}
discovery.ec2.availability_zones: [${availability_zones}]

cloud.aws.region: ${aws_region}
repositories.url.allowed_urls: ["${es_allowed_urls}"]

gateway.recover_after_time: 5m
gateway.expected_nodes: ${expected_nodes}

# circuit breakers
indices.breaker.fielddata.limit: ${elasticsearch_fielddata_limit}
EOF

# elasticsearch 2.4 specific settings
# note: we can check if 'bin/plugin' exists, this was renamed after 2.4
if [ ! -f '/usr/share/elasticsearch/bin/plugin' ]; then
  # in older versions of ES 'memory_lock' is called 'mlockall'
  sed -i 's/bootstrap.memory_lock/bootstrap.mlockall/g' /etc/elasticsearch/elasticsearch.yml
fi

# heap size
memory_in_bytes=`awk '/MemTotal/ {print $2}' /proc/meminfo`
heap_memory=$(( memory_in_bytes * ${elasticsearch_heap_memory_percent} / 100 / 1024 )) # take percentage of system memory, and convert to MB

# Make sure we're not over 31GB
max_memory=31000
if [[ "$heap_memory" -gt "$max_memory" ]]; then
  heap_memory="$max_memory"
fi

sudo sed -i 's/#\?MAX_LOCKED_MEMORY=.*/MAX_LOCKED_MEMORY=unlimited/' /etc/init.d/elasticsearch
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

# set LimitMEMLOCK for systemd (required for memory locking to work with systemd)
# https://www.elastic.co/guide/en/elasticsearch/reference/master/setting-system-settings.html
if [ "$(ps --no-headers -o comm 1)" = 'systemd' ]; then
  sudo mkdir -p /usr/lib/systemd/system/elasticsearch.service.d
  sudo echo -e '[Service]\nLimitMEMLOCK=infinity' > /usr/lib/systemd/system/elasticsearch.service.d/override.conf
  sudo systemctl daemon-reload
fi

# Start Elasticsearch
sudo service elasticsearch start

function elastic_status(){
  curl \
    --output /dev/null \
    --silent \
    --write-out "%{http_code}" \
    "http://${ELASTIC_HOST:-localhost:9200}" || true;
}

function elastic_wait(){
  echo 'waiting for elasticsearch service to come up';
  retry_count=30

  i=1
  while [[ "$i" -le "$retry_count" ]]; do
    if [[ $(elastic_status) -eq 200 ]]; then
      echo
      exit 0
    fi
    sleep 2
    printf "."
    i=$(($i + 1))
  done

  echo
  echo "Elasticsearch did not come up, check configuration"
  exit 1
}

# Wait for elasticsearch service to come up
elastic_wait;

# Put index template
# These settings will be automatically merged when creating new indices.
# Since elasticsearch v5+ this is now the recommended way to set node-specific settings.
# https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-templates.html
curl \
  -X PUT \
  -H 'Content-Type: application/json' \
  -d '{
    "template": ["pelias*"],
    "order": 0,
    "settings": {
      "search.slowlog.threshold.query.warn": "5s",
      "search.slowlog.threshold.query.info": "1s",
      "search.slowlog.threshold.fetch.warn": "5s",
      "indexing.slowlog.threshold.index.info": "10s"
    }
  }' \
  'localhost:9200/_template/pelias_global_settings'