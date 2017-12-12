apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: pelias-api
spec:
  replicas: {{ .Values.apiReplicas | default 1 }}
  minReadySeconds: 30
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  template:
    metadata:
      labels:
        app: pelias-api
    spec:
      containers:
        - name: pelias-api
          image: pelias/api:{{ .Values.apiDockerTag | default "latest" }}
          volumeMounts:
            - name: config-volume
              mountPath: /etc/config
          env:
            - name: PELIAS_CONFIG
              value: "/etc/config/pelias.json"
          resources:
            limits:
              memory: 3Gi
              cpu: 1.5
            requests:
              memory: 2Gi
              cpu: 0.5
      volumes:
        - name: config-volume
          configMap:
            name: pelias-json-configmap
            items:
              - key: pelias.json
                path: pelias.json
