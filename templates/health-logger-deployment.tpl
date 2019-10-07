apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: pelias-elasticsearch-healthlogger
spec:
  replicas: {{ .Values.healthlogger.replicas }}
  minReadySeconds: {{ .Values.healthlogger.minReadySeconds  }}
  strategy:
    rollingUpdate:
      maxSurge: {{ .Values.healthlogger.maxSurge }}
      maxUnavailable: 0
  template:
    metadata:
      labels:
        app: pelias-healthlogger
      annotations:
        image: pelias/elasticsearch-health-logger:{{ .Values.healthlogger.dockerTag }}
        elasticsearch: {{ .Values.elasticsearch.host }}
{{- if .Values.healthlogger.annotations }}
{{ toYaml .Values.healthlogger.annotations | indent 8 }}
{{- end }}
    spec:
      containers:
        - name: pelias-healthlogger
          image: pelias/elasticsearch-health-logger:{{ .Values.healthlogger.dockerTag }}
          resources:
            limits:
              memory: 0.5Gi
              cpu: 0.5
            requests:
              memory: {{ .Values.healthlogger.requests.memory | quote }}
              cpu: {{ .Values.healthlogger.requests.cpu | quote }}
          env:
          - name: ELASTICSEARCH_HOST
            value: "{{ .Values.elasticsearch.host }}:{{ .Values.elasticsearch.port}}"
          - name: WATCH_INTERVAL
            value: {{ .Values.healthlogger.watch_interval | quote }}
      nodeSelector:
{{ toYaml .Values.healthlogger.nodeSelector | indent 8 }}
