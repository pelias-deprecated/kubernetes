apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: pelias-placeholder
spec:
  replicas: {{ .Values.placeholder.replicas }}
  minReadySeconds: 30
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  template:
    metadata:
      labels:
        app: pelias-placeholder
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
          emptyDir: {}
