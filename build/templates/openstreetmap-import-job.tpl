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
          image: pelias/openstreetmap:master
          command: ["npm", "run", "download"]
          volumeMounts:
            - name: config-volume
              mountPath: /etc/config
            - name: data-volume
              mountPath: /data
          env:
            - name: PELIAS_CONFIG
              value: "/etc/config/pelias.json"
      containers:
      - name: openstreetmap-import-container
        image: pelias/openstreetmap:master
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
            memory: 6Gi
            cpu: 2
          requests:
            memory: 2Gi
            cpu: 1.5
      restartPolicy: Never
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
