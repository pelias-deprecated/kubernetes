apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: pelias-placeholder
spec:
  replicas: {{ .Values.placeholderReplicas | default 1 }}
  minReadySeconds: 30
  template:
    metadata:
      labels:
        app: pelias-placeholder
    spec:
      initContainers:
        - name: placeholder-download
          image: busybox
          command: ["sh", "-c",
            "mkdir -p /data/placeholder/ &&\n
             wget -O- http://pelias-data.s3.amazonaws.com/placeholder/store.sqlite3.gz | gunzip > /data/placeholder/store.sqlite3" ]
          volumeMounts:
            - name: data-volume
              mountPath: /data
          resources:
            limits:
              memory: 1Gi
              cpu: 1.1
            requests:
              memory: 512Mi
              cpu: 1
      containers:
        - name: pelias-placeholder
          image: pelias/placeholder:{{ .Values.placeholderDockerTag | default "latest" }}
          volumeMounts:
            - name: data-volume
              mountPath: /data
          env:
            - name: PLACEHOLDER_DATA
              value: "/data/placeholder/"
            - name: CPUS
              value: "1"
          resources:
            limits:
              memory: 1Gi
              cpu: 2
            requests:
              memory: 512Mi
              cpu: 1
      volumes:
        - name: data-volume
          emptyDir: {}
