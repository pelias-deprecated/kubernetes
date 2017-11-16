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
            "url": "http://pelias-placeholder-service:3102/"
          },
          "language": {
            "url": "http://pelias-placeholder-service:3102/"
          },
          "interpolation": {
            "url": "http://pelias-interpolation-service:3102/"
          },
          "pip": {
            "url": "http://pelias-pip-service:3102/"
          }
        }
      },
      "acceptance-tests": {
        "endpoints": {
          "local": "http://pelias-api-service:3100/v1/"
        }
      },
      "logger": {
        "level": "debug",
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
          "countryCode": "us"
        },
        "openaddresses": {
          "datapath": "/data/openaddresses",
          "files": ["us/ma/city_of_boston.csv"]
        },
        "openstreetmap": {
          "download": [{
              "sourceURL": "https://s3.amazonaws.com/metro-extracts.mapzen.com/boston_massachusetts.osm.pbf"
          }],
          "datapath": "/data/openstreetmap",
          "import": [{
            "filename": "boston_massachusetts.osm.pbf"
          }]
        },
        "polyline": {
          "datapath": "/data/polylines",
          "files": ["extract.0sv"]
        },
        "whosonfirst": {
          "importVenues": false,
          "importPlace": " 85950361",
          "api_key": "{{ .Values.apiKey }}",
          "datapath": "/data/whosonfirst/"
        }
      }
    }
