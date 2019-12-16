apiVersion: apps/v1
kind: Deployment
metadata:
  name: pelias-placeholder
spec:
  replicas: {{ .Values.placeholder.replicas }}
  minReadySeconds: {{ .Values.placeholder.minReadySeconds }}
  strategy:
    rollingUpdate:
      maxSurge: {{ .Values.placeholder.maxSurge }}
      maxUnavailable: {{ .Values.placeholder.maxUnavailable }}
  template:
    metadata:
      labels:
        app: pelias-placeholder
      annotations:
{{- if .Values.placeholder.annotations }}
{{ toYaml .Values.placeholder.annotations | indent 8 }}
{{- end }}
    spec:
      initContainers:
        - name: download
          image: pelias/placeholder:{{ .Values.placeholder.dockerTag }}
          env:
            - name: DOWNLOAD_URL
              value: {{ .Values.placeholder.storeURL | quote }}
          command: ["sh", "-c", {{ .Values.placeholder.downloadCommand | quote }} ]
          volumeMounts:
            - name: data-volume
              mountPath: /data
          resources:
            limits:
              memory: 1Gi
              cpu: 1.1
              ephemeral-storage: {{ .Values.placeholder.limits.ephemeral_storage }}
            requests:
              memory: 100Mi
              cpu: 0.2
              ephemeral-storage: {{ .Values.placeholder.requests.ephemeral_storage }}
      containers:
        - name: pelias-placeholder
          image: pelias/placeholder:{{ .Values.placeholder.dockerTag }}
          volumeMounts:
            - name: data-volume
              mountPath: /data
          env:
            - name: PLACEHOLDER_DATA
              value: "/data/placeholder/"
            - name: CPUS
              value: "{{ .Values.placeholder.cpus }}"
          resources:
            limits:
              memory: 1Gi
              cpu: 2
              ephemeral-storage: {{ .Values.placeholder.limits.ephemeral_storage }}
            requests:
              memory: {{ .Values.placeholder.requests.memory | quote }}
              cpu: {{ .Values.placeholder.requests.cpu | quote }}
              ephemeral-storage: {{ .Values.placeholder.requests.ephemeral_storage }}
      volumes:
        - name: data-volume
        {{- if .Values.placeholder.pvc.create }}
          persistentVolumeClaim:
            claimName: {{ .Values.placeholder.pvc.name }}
        {{- else }}
          emptyDir: {}
	{{- end }}
      nodeSelector:
{{ toYaml .Values.placeholder.nodeSelector | indent 8 }}
