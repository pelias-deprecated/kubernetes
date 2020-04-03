apiVersion: apps/v1
kind: Deployment
metadata:
  name: pelias-interpolation
spec:
  replicas: {{ .Values.interpolation.replicas }}
  minReadySeconds: {{ .Values.interpolation.minReadySeconds }}
  selector:
    matchLabels:
      app: pelias-interpolation
  strategy:
    rollingUpdate:
      maxSurge: {{ .Values.interpolation.maxSurge }}
      maxUnavailable: {{ .Values.interpolation.maxUnavailable }}
  template:
    metadata:
      labels:
        app: pelias-interpolation
      annotations:
{{- if .Values.interpolation.annotations }}
{{ toYaml .Values.interpolation.annotations | indent 8 }}
{{- end }}
    spec:
      initContainers:
        - name: download
          image: pelias/interpolation:{{ .Values.interpolation.dockerTag }}
          env:
            - name: DOWNLOAD_PATH
              value: {{ .Values.interpolation.downloadPath | quote }}
          command: ["sh", "-c", {{ .Values.interpolation.downloadCommand | quote }} ]
          volumeMounts:
            - name: data-volume
              mountPath: /data
          resources:
            limits:
              memory: 3Gi
              cpu: 2
              ephemeral-storage: {{ .Values.interpolation.limits.ephemeral_storage }}
            requests:
              memory: 512Mi
              cpu: 0.1
              ephemeral-storage: {{ .Values.interpolation.requests.ephemeral_storage }}
      containers:
        - name: pelias-interpolation
          image: pelias/interpolation:{{ .Values.interpolation.dockerTag }}
          volumeMounts:
            - name: data-volume
              mountPath: /data
            - name: config-volume
              mountPath: /etc/config
          env:
            - name: PELIAS_CONFIG
              value: "/etc/config/pelias.json"
          resources:
            limits:
              memory: 3Gi
              cpu: 2
              ephemeral-storage: {{ .Values.interpolation.limits.ephemeral_storage }}
            requests:
              memory: {{ .Values.interpolation.requests.memory | quote }}
              cpu: {{ .Values.interpolation.requests.cpu | quote }}
              ephemeral-storage: {{ .Values.interpolation.requests.ephemeral_storage }}
      volumes:
        - name: data-volume
        {{- if .Values.interpolation.pvc.create }}
          persistentVolumeClaim:
            claimName: {{ .Values.interpolation.pvc.name }}
        {{- else }}
          emptyDir: {}
        {{- end }}
        - name: config-volume
          configMap:
            name: pelias-json-configmap
            items:
              - key: pelias.json
                path: pelias.json
      nodeSelector:
{{ toYaml .Values.interpolation.nodeSelector | indent 8 }}
