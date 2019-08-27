apiVersion: extensions/v1beta1
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
          image: busybox
          command: ["sh", "-c",
            "mkdir -p /data/placeholder/ &&\n
             wget -O- {{ .Values.placeholder.storeURL }} | gunzip > /data/placeholder/store.sqlite3" ]
          volumeMounts:
            - name: data-volume
              mountPath: /data
          resources:
            limits:
              memory: 1Gi
              cpu: 1.1
            requests:
              memory: 512Mi
              cpu: 0.2
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
            requests:
              memory: 512Mi
              cpu: 0.1
      volumes:
        - name: data-volume
        {{- if .Values.placeholder.pvc.create }}
          persistentVolumeClaim:
            claimName: {{ .Values.placeholder.pvc.name }}
        {{- else }}
          emptyDir: {}
	{{- end }}
      {{- with .Values.placeholder.nodeSelector }}
      nodeSelector:
{{ toYaml . | indent 8 }}
      {{- end }}
