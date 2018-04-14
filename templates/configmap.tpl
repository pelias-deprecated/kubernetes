apiVersion: v1
kind: ConfigMap
metadata:
  name: pelias-json-configmap
data:
  pelias.json: |
    {
      "esclient": {
        "hosts": [{
          "host": "{{ .Values.elasticsearchHost }}"
        }]
      },
      "api": {
        "indexName": "{{ .Values.apiIndexName }}",
        "services": {
          "placeholder": {
            "url": "{{ .Values.placeholderHost }}",
            "timeout": 5000
          },
          {{ if ne .Values.interpolationReplicas "0" }}
          "interpolation": {
            "url": "{{ .Values.interpolationHost }}",
            "timeout": 5000
          },
          {{ end }}
          "libpostal": {
            "url": "{{ .Values.libpostalHost }}",
            "timeout": 5000
          },
          "pip": {
            "url": "{{ .Values.pipHost }}",
            "timeout": 5000
          }
        }
      },
      "acceptance-tests": {
        "endpoints": {
          "local": "http://pelias-api-service:3100/v1/"
        }
      },
      "logger": {
        "level": "info",
        "timestamp": true
      },
      "imports": {
        "adminLookup": {
            "enabled": true,
            "maxConcurrentReqs": 20
        },
        "services": {
          "pip": {
            "url": "http://pelias-pip-service:3102",
            "timeout": 5000
          }
        },
        "geonames": {
          "datapath": "/data/geonames",
          "countryCode": "ALL"
        },
        "openaddresses": {
          "datapath": "/data/openaddresses",
          "files": []
        },
        "openstreetmap": {
          "download": [{
              "sourceURL": "http://planet.us-east-1.mapzen.com/planet-latest.osm.pbf"
          }],
          "datapath": "/data/openstreetmap",
          "import": [{
            "filename": "planet-latest.osm.pbf"
          }]
        },
        "polyline": {
          "datapath": "/data/polylines",
          "files": ["extract.0sv"]
        },
        "whosonfirst": {
          "importVenues": false,
          "datapath": "/data/whosonfirst"
        }
      }
    }
