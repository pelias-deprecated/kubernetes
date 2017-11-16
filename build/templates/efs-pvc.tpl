kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: pelias-build-pvc
spec:
  storageClassName: ""
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 500Gi
