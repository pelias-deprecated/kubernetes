{{- if (and .Values.dashboard.domain .Values.dashboard.enabled) }}
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: pelias-dashboard-ingress
  annotations:
    kubernetes.io/ingress.class: nginx
    kubernetes.io/tls-acme: "true"
spec:
  rules:
  - host: {{ .Values.dashboard.domain }}
    http:
      paths:
      - path: /
        backend:
          serviceName: pelias-dashboard-service
          servicePort: 3030
  tls:
  - secretName: pelias-dashboard-tls
    hosts:
      - {{ .Values.dashboard.domain }}
{{- end -}}
