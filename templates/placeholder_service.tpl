apiVersion: v1
kind: Service
metadata:
    name: pelias-placeholder-service
spec:
    selector:
        app: pelias-placeholder
    ports:
        - protocol: TCP
          port: 3000
    type: ClusterIP
