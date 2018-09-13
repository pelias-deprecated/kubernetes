{{- if (or (.Values.interpolationEnabled) (.Values.interpolation.enabled))  }}
apiVersion: v1
kind: Service
metadata:
    name: pelias-interpolation-service
spec:
    selector:
        app: pelias-interpolation
    ports:
        - protocol: TCP
          port: 3000
    type: ClusterIP
{{- end -}}
