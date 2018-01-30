apiVersion: v1
kind: Service
metadata:
  name: pelias-libpostal-service
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-internal: 0.0.0.0/0
spec:
    selector:
        app: pelias-libpostal
    ports:
        - protocol: TCP
          port: 8080
    type: LoadBalancer
