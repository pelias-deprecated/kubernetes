#!/bin/bash -ex

cd /tmp

# note: the download servers changed between elasticsearch versions
OLD_HOST="download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/deb/elasticsearch/${ELASTICSEARCH_VERSION}"
NEW_HOST='artifacts.elastic.co/downloads/elasticsearch'

# download elasticsearch .deb package
if [[ "${ELASTICSEARCH_VERSION}" == "2."* ]]; then
  wget "https://${OLD_HOST}/elasticsearch-${ELASTICSEARCH_VERSION}.deb"
else
  wget "https://${NEW_HOST}/elasticsearch-${ELASTICSEARCH_VERSION}.deb"
fi

# install .deb package
sudo dpkg -i "elasticsearch-${ELASTICSEARCH_VERSION}.deb"

# set permissions
cd /usr/share/elasticsearch
sudo chown elasticsearch:elasticsearch -R .

# install plugins
# note: the plugin installation process changed between elasticsearch versions
# note: the 'cloud-aws' plugin was split in to 'repository-s3' & 'discovery-ec2'
# see: https://www.elastic.co/guide/en/elasticsearch/plugins/5.6/cloud-aws.html
cd /usr/share/elasticsearch/bin
if [[ "${ELASTICSEARCH_VERSION}" == "2."* ]]; then
  sudo ./plugin install --verbose --batch analysis-icu
  sudo ./plugin install --verbose --batch cloud-aws
else
  sudo ./elasticsearch-plugin install --verbose --batch analysis-icu
  sudo ./elasticsearch-plugin install --verbose --batch repository-s3
  sudo ./elasticsearch-plugin install --verbose --batch discovery-ec2
fi