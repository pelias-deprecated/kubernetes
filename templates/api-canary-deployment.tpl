{{- if .Values.api.canaryDockerTag }}
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: pelias-api-canary
spec:
  replicas: {{ .Values.api.canaryReplicas | default 1 }}
  minReadySeconds: {{ .Values.api.minReadySeconds  | default 10 }}
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
    spec:
      containers:
        - name: pelias-api
          image: pelias/api:{{ .Values.api.canaryDockerTag | default "latest" }}
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
              memory: {{ .Values.api.requests.memory | quote | default "0.5Gi" }}
              cpu: {{ .Values.api.requests.cpu | quote | default "0.25" }}
      volumes:
        - name: config-volume
          configMap:
            name: pelias-json-configmap
            items:
              - key: pelias.json
                path: pelias.json
{{- end -}}
