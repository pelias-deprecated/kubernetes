apiVersion: v1
kind: ConfigMap
metadata:
  name: pelias-json-configmap
data:
  pelias.json: |
    {
      "esclient": {
        "hosts": [{
          "host": {{ .Values.elasticsearch.host | quote}},
          "port": {{ .Values.elasticsearch.port }},
          "protocol": {{ .Values.elasticsearch.protocol | quote }}
          {{- if .Values.elasticsearch.auth }}
          ,"auth": "{{ .Values.elasticsearch.auth }}"
          {{- end }}
        }]
      },
      "elasticsearch": {
        "settings": {
          "index": {
            "number_of_replicas": "0",
            "number_of_shards": "12",
            "refresh_interval": "1m"
          }
        }
      },
      "api": {
        "autocomplete": {
          "exclude_address_length": {{ .Values.api.autocomplete.exclude_address_length }}
        },
        "attributionURL": "{{ .Values.apiAttributionURL | .Values.api.attributionURL }}",
        "indexName": "{{ .Values.apiIndexName | .Values.api.indexName }}",
        "services": {
          {{ if .Values.placeholderEnabled  }}
          "placeholder": {
            "url": "{{ .Values.placeholderHost }}",
            "retries": {{ .Values.placeholderRetries | default 1 }},
            "timeout": {{ .Values.placeholderTimeout | default 5000 }}
          },
          {{- end }}
          {{- if .Values.interpolationEnabled | default .Values.interpolation.enabled }}
          "interpolation": {
            "url": "{{ .Values.interpolationHost | default .Values.interpolation.host }}",
            "retries": {{ .Values.interpolationRetries | default 1 }},
            "timeout": {{ .Values.interpolationTimeout | default 5000 }}
          },
          {{- end }}
          {{- if .Values.pipEnabled | default .Values.pip.enabled }}
          "pip": {
            "url": "{{ .Values.pipHost | default .Values.pip.host}}",
            "retries": {{ .Values.pipRetries | default 1 }},
            "timeout": {{ .Values.pipTimeout | default 5000 }}
          },
          {{- end }}
          "libpostal": {
            "url": "{{ .Values.libpostalHost }}",
            "retries": {{ .Values.libpostalRetries | default 1 }},
            "timeout": {{ .Values.libpostalTimeout | default 5000 }}
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
        "json": true,
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
          "sqlite": {{ .Values.whosonfirst.sqlite | default false }},
          {{ if .Values.whosonfirst.dataHost }}
          "dataHost": "{{ .Values.whosonfirst.dataHost}}",
          {{ end }}
          "importVenues": false,
          "importPostalcodes": true,
          "datapath": "/data/whosonfirst"
        }
      }
    }
