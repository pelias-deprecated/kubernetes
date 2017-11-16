apiVersion: v1
kind: Service
metadata:
    name: pelias-api-service
spec:
    selector:
        app: pelias-api
    ports:
        - protocol: TCP
          port: 3100
    type:{{ if .Values.externalAPIService }} LoadBalancer {{ else }} ClusterIP {{ end }}
