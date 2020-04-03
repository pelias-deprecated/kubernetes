apiVersion: apps/v1
kind: Deployment
metadata:
  name: pelias-pip
spec:
  replicas: {{ .Values.pip.replicas }}
  minReadySeconds: {{ .Values.pip.minReadySeconds }}
  selector:
    matchLabels:
      app: pelias-pip
  strategy:
    rollingUpdate:
      maxSurge: {{ .Values.pip.maxSurge }}
      maxUnavailable: {{ .Values.pip.maxUnavailable }}
  template:
    metadata:
      labels:
        app: pelias-pip
      annotations:
{{- if .Values.pip.annotations }}
{{ toYaml .Values.pip.annotations | indent 8 }}
{{- end }}
    spec:
      initContainers:
        - name: download
          image: pelias/pip-service:{{ .Values.pip.dockerTag }}
          command: ["sh", "-c", {{ .Values.pip.downloadCommand | quote }} ]
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
              ephemeral-storage: {{ .Values.pip.limits.ephemeral_storage }}
            requests:
              memory: 1Gi
              cpu: 0.1
              ephemeral-storage: {{ .Values.pip.requests.ephemeral_storage }}
      containers:
        - name: pelias-pip
          image: pelias/pip-service:{{ .Values.pip.dockerTag }}
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
              memory: {{ .Values.pip.limits.memory }}
              cpu: {{ .Values.pip.limits.cpu }}
              ephemeral-storage: {{ .Values.pip.limits.ephemeral_storage }}
            requests:
              memory: {{ .Values.pip.requests.memory | quote }}
              cpu: {{ .Values.pip.requests.cpu | quote }}
              ephemeral-storage: {{ .Values.pip.requests.ephemeral_storage }}
          readinessProbe:
            httpGet:
              path: /12/12
              port: 3102
            initialDelaySeconds: {{ .Values.pip.initialDelaySeconds }}
      volumes:
        - name: config-volume
          configMap:
            name: pelias-json-configmap
            items:
              - key: pelias.json
                path: pelias.json
        - name: data-volume
          {{- if .Values.pip.pvc.create }}
          persistentVolumeClaim:
            claimName: {{ .Values.pip.pvc.name }}
          {{- else }}
          emptyDir: {}
          {{- end }}
      nodeSelector:
{{ toYaml .Values.pip.nodeSelector | indent 8 }}
