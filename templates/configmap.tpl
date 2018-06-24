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
        "attributionURL": "{{ .Values.apiAttributionURL }}",
        "indexName": "{{ .Values.apiIndexName }}",
        "services": {
         {{ if .Values.placeholderEnabled  }}
          "placeholder": {
            "url": "{{ .Values.placeholderHost }}",
            "retries": {{ .Values.placeholderRetries | default 1 }},
            "timeout": {{ .Values.placeholderTimeout | default 5000 }}
          },
         {{ end }}
          {{ if .Values.interpolationEnabled }}
          "interpolation": {
            "url": "{{ .Values.interpolationHost }}",
            "retries": {{ .Values.interpolationRetries | default 1 }},
            "timeout": {{ .Values.interpolationTimeout | default 5000 }}
          },
          {{ end }}
          {{ if .Values.pipEnabled }}
          "pip": {
            "url": "{{ .Values.pipHost }}",
            "retries": {{ .Values.pipRetries | default 1 }},
            "timeout": {{ .Values.pipTimeout | default 5000 }}
          },
          {{ end }}
          "libpostal": {
            "url": "{{ .Values.libpostalHost }}",
            "retries": {{ .Values.libpostalRetries | default 1 }},
            "timeout": {{ .Values.libpostalTimeout | default 5000 }}
          } # for now, as a hack, libpostal cannot be disabled because there needs to be no comma only on the LAST element of a JSON object
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
