apiVersion: batch/v1
kind: Job
metadata:
  name: polylines-import
spec:
  template:
    metadata:
      name: polylines-import-pod
    spec:
      initContainers:
        - name: polylines-download
          image: busybox
          command: ["sh", "-c"]
          args: ["mkdir -p /data/polylines && wget -O- https://s3.amazonaws.com/pelias-data/road-network.gz | gunzip > /data/polylines/extract.0sv"]
          volumeMounts:
            - name: data-volume
              mountPath: /data
      containers:
      - name: polylines-import-container
        image: pelias/polylines:latest #{{ .Values.polylinesDockerTag | default "latest" }}
        command: ["npm", "start"]
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
            memory: 8Gi
          requests:
            memory: 6Gi
      restartPolicy: OnFailure
      volumes:
        - name: config-volume
          configMap:
            name: pelias-json-configmap
            items:
              - key: pelias.json
                path: pelias.json
        - name: data-volume
          persistentVolumeClaim:
            claimName: pelias-build-pvc
