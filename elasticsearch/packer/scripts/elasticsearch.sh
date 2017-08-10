#!/bin/bash -ex

cd /tmp
wget https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/deb/elasticsearch/${ELASTICSEARCH_VERSION}/elasticsearch-${ELASTICSEARCH_VERSION}.deb

sudo dpkg -i elasticsearch-${ELASTICSEARCH_VERSION}.deb

cd /usr/share/elasticsearch
sudo chown elasticsearch:elasticsearch -R .
