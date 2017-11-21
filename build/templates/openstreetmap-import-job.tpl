apiVersion: batch/v1
kind: Job
metadata:
  name: openstreetmap-import
spec:
  template:
    metadata:
      name: openstreetmap-import
    spec:
      initContainers:
      - name: openstreetmap-download
        image: pelias/openstreetmap:{{ .Values.openstreetmapDockerTag | default "latest"}}
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
            memory: 1Gi
            cpu: 2
          requests:
            memory: 256Mi
            cpu: 0.5
      containers:
      - name: openstreetmap-import-container
        image: pelias/openstreetmap:{{ .Values.openstreetmapDockerTag | default "latest"}}
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
            cpu: 3
          requests:
            memory: 4Gi
            cpu: 1.5
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
