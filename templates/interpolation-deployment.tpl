apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: pelias-interpolation
spec:
  replicas: {{ .Values.interpolation.replicas }}
  minReadySeconds: {{ .Values.interpolation.minReadySeconds }}
  strategy:
    rollingUpdate:
      maxSurge: {{ .Values.interpolation.maxSurge }}
      maxUnavailable: {{ .Values.interpolation.maxUnavailable }}
  template:
    metadata:
      labels:
        app: pelias-interpolation
      annotations:
        checksum/config: {{ include (print $.Template.BasePath "/configmap.tpl") . | sha256sum }}
{{- if .Values.interpolation.annotations }}
{{ toYaml .Values.interpolation.annotations | indent 8 }}
{{- end }}
    spec:
      initContainers:
        - name: download
          image: busybox
          command: [ "sh", "-c",
            "mkdir -p /data/interpolation/ &&\n
             wget -O - {{ .Values.interpolation.downloadPath }}/street.db.gz | gunzip > /data/interpolation/street.db &\n
             wget -O - {{ .Values.interpolation.downloadPath }}/address.db.gz | gunzip > /data/interpolation/address.db" ]
          volumeMounts:
            - name: data-volume
              mountPath: /data
          resources:
            limits:
              memory: 3Gi
              cpu: 2
            requests:
              memory: 512Mi
              cpu: 0.1
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
            requests:
              memory: {{ .Values.interpolation.requests.memory | quote }}
              cpu: {{ .Values.interpolation.requests.cpu | quote }}
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
