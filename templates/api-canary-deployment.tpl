{{- if .Values.api.canaryDockerTag }}
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: pelias-api-canary
spec:
  replicas: {{ .Values.api.canaryReplicas }}
  minReadySeconds: {{ .Values.api.minReadySeconds }}
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  template:
    metadata:
      labels:
        app: {{ if .Values.api.privateCanary }} pelias-api-private-canary {{ else }} pelias-api {{ end }}
      annotations:
        checksum/config: {{ include (print $.Template.BasePath "/configmap.tpl") . | sha256sum }}
        image: pelias/api:{{ .Values.api.canaryDockerTag }}
        elasticsearch: {{ .Values.elasticsearch.host }}
    spec:
      containers:
        - name: pelias-api
          image: pelias/api:{{ .Values.api.canaryDockerTag }}
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
      {{- with .Values.nodeSelector }}
      nodeSelector:
{{ toYaml . | indent 8 }}
      {{- end }}
{{- end -}}
