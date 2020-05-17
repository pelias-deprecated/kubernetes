apiVersion: v1
kind: Service
metadata:
    name: pelias-api-service
    annotations:
      {{ if .Values.api.privateLoadBalancer }}service.beta.kubernetes.io/aws-load-balancer-internal: 0.0.0.0/0{{ end }}
spec:
    selector:
        app-group: pelias-api
    ports:
        - protocol: TCP
          port: 3100
    type:{{ if .Values.api.externalService }} LoadBalancer {{ else }} ClusterIP {{ end }}
