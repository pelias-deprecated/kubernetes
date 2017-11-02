apiVersion: batch/v1
kind: Job
metadata:
  name: openaddresses-import
spec:
  template:
    metadata:
      name: openaddresses-import-pod
    spec:
      initContainers:
        - name: openaddresses-download
          image: pelias/openaddresses:master
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
      - name: openaddresses-import-container
        image: pelias/openaddresses:master
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
            memory: 3Gi
            cpu: 1.5
          requests:
            memory: 2Gi
            cpu: 1
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
