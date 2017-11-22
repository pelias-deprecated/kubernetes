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
        "services": {
          "placeholder": {
            "url": "http://pelias-placeholder-service:3000/",
            "timeout": 5000
          },
          "interpolation": {
            "url": "http://pelias-interpolation-service:3102/",
            "timeout": 5000
          },
          "pip": {
            "url": "http://pelias-pip-service:3102/",
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
            "url": "http://pelias-pip-service:3102"
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
