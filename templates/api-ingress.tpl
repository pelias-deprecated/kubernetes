{{- if .Values.api.domain }}
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: pelias-api-ingress
  annotations:
    kubernetes.io/ingress.class: nginx
    kubernetes.io/tls-acme: "true"
spec:
  rules:
  - host: {{ .Values.api.domain }}
    http:
      paths:
      - path: /
        backend:
          serviceName: pelias-api-service
          servicePort: 3100
  tls:
  - secretName: pelias-api-tls
    hosts:
      - {{ .Values.api.domain }}
{{- end -}}
