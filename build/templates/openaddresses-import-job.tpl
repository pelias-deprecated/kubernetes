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
      - name: setup
        image: busybox
        command: ["mkdir", "-p", "/data/openaddresses"]
        volumeMounts:
        - name: data-volume
          mountPath: /data
      - name: openaddresses-download
        image: pelias/openaddresses:{{ .Values.openaddressesDockerTag | default "latest" }}
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
            memory: 4Gi
            cpu: 1.5
          requests:
            memory: 256Mi
            cpu: 0.5
      containers:
      - name: openaddresses-import-container
        image: pelias/openaddresses:{{ .Values.openaddressesDockerTag | default "latest" }}
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
            memory: 2Gi
            cpu: 2
          requests:
            memory: 512Mi
            cpu: 1
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
