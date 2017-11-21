apiVersion: batch/v1
kind: Job
metadata:
  name: geonames-import
spec:
  template:
    metadata:
      name: geonames-import-pod
    spec:
      initContainers:
        - name: geonames-download
          image: pelias/geonames:{{ .Values.geonamesDockerTag | default "latests" }}
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
              memory: 512Mi
              cpu: 1
            requests:
              memory: 512Mi
              cpu: 1
      containers:
      - name: geonames-import-container
        image: pelias/geonames:{{ .Values.geonamesDockerTag | default "latests" }}
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
