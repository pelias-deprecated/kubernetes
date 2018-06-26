apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: pelias-pip
spec:
  replicas: {{ .Values.pipReplicas | default 1 }}
  minReadySeconds: 60
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: {{ .Values.pipMaxUnavailable | default 0 }}
  template:
    metadata:
      labels:
        app: pelias-pip
    spec:
      initContainers:
        - name: wof-download
          image: pelias/pip-service:{{ .Values.pipDockerTag | default "latest" }}
          command: ["npm", "run", "download"]
          volumeMounts:
            - name: config-volume
              mountPath: /etc/config
            - name: data-volume
              mountPath: /data
          env:
            - name: PELIAS_CONFIG
              value: "/etc/config/pelias.json"
          resources:
            limits:
              memory: 3Gi
              cpu: 4
            requests:
              memory: 1Gi
              cpu: 1
      containers:
        - name: pelias-pip
          image: pelias/pip-service:{{ .Values.pipDockerTag | default "latest" }}
          volumeMounts:
            - name: config-volume
              mountPath: /etc/config
            - name: data-volume
              mountPath: /data
          env:
            - name: PELIAS_CONFIG
              value: "/etc/config/pelias.json"
          resources:
            limits:
              memory: 10Gi
              cpu: 3
            requests:
              memory: 5Gi
              cpu: 0.1
          readinessProbe:
            httpGet:
              path: /12/12
              port: 3102
            initialDelaySeconds: 120 #PIP service takes a long time to start up
      volumes:
        - name: config-volume
          configMap:
            name: pelias-json-configmap
            items:
              - key: pelias.json
                path: pelias.json
        - name: data-volume
          emptyDir: {}
