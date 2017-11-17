apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: pelias-api
spec:
  replicas: {{ .Values.apiReplicas | default 1 }}
  template:
    metadata:
      labels:
        app: pelias-api
    spec:
      containers:
        - name: pelias-api
          image: pelias/api:{{ .Values.apiDockerTag | default "production" }}
          volumeMounts:
            - name: config-volume
              mountPath: /etc/config
          env:
            - name: PELIAS_CONFIG
              value: "/etc/config/pelias.json"
          resources:
            limits:
              memory: 4Gi
            requests:
              memory: 3Gi
      volumes:
        - name: config-volume
          configMap:
            name: pelias-json-configmap
            items:
              - key: pelias.json
                path: pelias.json
