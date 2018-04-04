apiVersion: v1
kind: Service
metadata:
    name: pelias-api-service
    annotations:
      {{ if .Values.privateAPILoadBalancer }}service.beta.kubernetes.io/aws-load-balancer-internal: 0.0.0.0/0{{ end }}
spec:
    selector:
        app: pelias-api
    ports:
        - protocol: TCP
          port: 3100
    type:{{ if .Values.externalAPIService }} LoadBalancer {{ else }} ClusterIP {{ end }}
