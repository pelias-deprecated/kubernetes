{{- if (or (.Values.pipEnabled) (.Values.pip.enabled)) }}
apiVersion: v1
kind: Service
metadata:
    name: pelias-pip-service
spec:
    selector:
        app: pelias-pip
    ports:
        - protocol: TCP
          port: 3102
    type: ClusterIP
{{- end -}}
