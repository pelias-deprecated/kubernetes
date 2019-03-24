apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: pelias-api
spec:
  replicas: {{ .Values.api.replicas }}
  minReadySeconds: {{ .Values.api.minReadySeconds  }}
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  template:
    metadata:
      labels:
        app: pelias-api
      annotations:
        image: pelias/api:{{ .Values.api.dockerTag }}
        checksum/config: {{ include (print $.Template.BasePath "/configmap.tpl") . | sha256sum }}
        elasticsearch: {{ .Values.elasticsearch.host }}
{{- if .Values.api.annotations }}
{{ toYaml .Values.api.annotations | indent 8 }}
{{- end }}
    spec:
      containers:
        - name: pelias-api
          image: pelias/api:{{ .Values.api.dockerTag }}
          volumeMounts:
            - name: config-volume
              mountPath: /etc/config
          env:
            - name: PELIAS_CONFIG
              value: "/etc/config/pelias.json"
          resources:
            limits:
              memory: 0.5Gi
              cpu: 1.5
            requests:
              memory: {{ .Values.api.requests.memory | quote }}
              cpu: {{ .Values.api.requests.cpu | quote }}
      volumes:
        - name: config-volume
          configMap:
            name: pelias-json-configmap
            items:
              - key: pelias.json
                path: pelias.json
