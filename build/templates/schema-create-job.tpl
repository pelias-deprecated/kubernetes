apiVersion: batch/v1
kind: Job
metadata:
  name: schema-create
spec:
  template:
    metadata:
      name: schema-create
    spec:
      containers:
      - name: schema-create
        image: pelias/schema
        command: ["npm", "run", "create_index"]
        volumeMounts:
          - name: config-volume
            mountPath: /etc/config
        env:
          - name: PELIAS_CONFIG
            value: "/etc/config/pelias.json"
        resources:
          limits:
            memory: 1Gi
            cpu: 0.1
          requests:
            memory: 1Gi
            cpu: 0.1
      restartPolicy: Never
      volumes:
        - name: config-volume
          configMap:
            name: pelias-json-configmap
            items:
              - key: pelias.json
                path: pelias.json
