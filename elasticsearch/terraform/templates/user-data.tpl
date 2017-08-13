#!/bin/bash
set -e

# Ideally move all this to a proper config management tool
#
# Configure elasticsearch

cat <<'EOF' >/etc/elasticsearch/elasticsearch.yml
cluster.name: ${es_cluster_name}

# our init.d script sets the default to this as well
path.data: ${elasticsearch_data_dir}
path.logs: ${elasticsearch_log_dir}

bootstrap.mlockall: true
network.host: _ec2:privateIpv4_
discovery.type: ec2
cloud.aws.region: ${aws_region}
cloud.aws.groups: ${aws_security_group}
repositories.url.allowed_urls: ["${es_allowed_urls}"]
EOF

# heap size
memory_in_bytes=`awk '/MemTotal/ {print $2}' /proc/meminfo`
heap_memory=$(( memory_in_bytes * 6 / 10 / 1024 )) # take 60% of system memory, and convert to MB
sudo sed -i 's/#MAX_LOCKED_MEMORY=unlimited/MAX_LOCKED_MEMORY=unlimited/' /etc/init.d/elasticsearch
sudo sed -i "s/#ES_HEAP_SIZE=.*$/ES_HEAP_SIZE=${heap_memory}m/" /etc/default/elasticsearch

# data volume
sudo mkfs -t ext4 ${data_volume_name}
sudo mkdir -p ${elasticsearch_data_dir}
sudo mount ${data_volume_name} ${elasticsearch_data_dir}
sudo echo "${data_volume_name} ${elasticsearch_data_dir} ext4 defaults,nofail 0 2" >> /etc/fstab
sudo chown -R elasticsearch:elasticsearch ${elasticsearch_data_dir}

# log volume
sudo mkfs -t ext4 ${log_volume_name}
sudo mkdir -p ${elasticsearch_log_dir}
sudo mount ${log_volume_name} ${elasticsearch_log_dir}
sudo echo "${log_volume_name} ${elasticsearch_log_dir} ext4 defaults,nofail 0 2" >> /etc/fstab
sudo chown -R elasticsearch:elasticsearch ${elasticsearch_log_dir}

# Start Elasticsearch
sudo service elasticsearch start
