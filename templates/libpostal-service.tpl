apiVersion: v1
kind: Service
metadata:
  name: pelias-libpostal-service
spec:
    selector:
        app: pelias-libpostal
    ports:
        - protocol: TCP
          port: 4400
    type: ClusterIP
