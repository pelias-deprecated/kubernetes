apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: pelias-interpolation
spec:
  replicas: {{ .Values.interpolationReplicas | default 1 }}
  template:
    metadata:
      labels:
        app: pelias-interpolation
    spec:
      initContainers:
        - name: interpolation-download
          image: busybox
          command: ["sh", "-c",
            "mkdir -p /data/interpolation/ &&\n
             wget -O- http://pelias-data.s3.amazonaws.com/interpolation/current/street.db.gz | gunzip > /data/interpolation/street.db &\n
             wget -O- http://pelias-data.s3.amazonaws.com/interpolation/current/address.db.gz | gunzip > /data/interpolation/address.db" ]
          volumeMounts:
            - name: data-volume
              mountPath: /data
      containers:
        - name: pelias-interpolation
          image: pelias/interpolation:{{ .Values.interpolationDockerTag | default "latest" }}
          volumeMounts:
            - name: data-volume
              mountPath: /data
          resources:
            limits:
              memory: 3Gi
              cpu: 2
            requests:
              memory: 2Gi
              cpu: 1
      volumes:
        - name: data-volume
          emptyDir: {}
