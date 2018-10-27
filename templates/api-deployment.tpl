apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: pelias-api
spec:
  replicas: {{ .Values.api.replicas | default 1 }}
  minReadySeconds: {{ .Values.api.minReadySeconds  | default 10 }}
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  template:
    metadata:
      labels:
        app: pelias-api
      annotations:
        checksum/config: {{ include (print $.Template.BasePath "/configmap.tpl") . | sha256sum }}
    spec:
      containers:
        - name: pelias-api
          image: pelias/api:{{ .Values.api.dockerTag | default "latest" }}
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
