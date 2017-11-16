apiVersion: v1
kind: PersistentVolume
metadata:
  name: pelias-build-volume
  annotations:
    volume.beta.kubernetes.io/mount-options: "hard,nfsvers=4.1,retrans=2,rsize=1048576,wsize=1048576"
spec:
  capacity:
    storage: 500Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  {{- if ( gt .Capabilities.KubeVersion.Major "1" ) or ( eq .Capabilities.KubeVersion.Major 1 and gt .Capabilities.KubeVersion.Minor "7" ) }} # save this for k8s 1.8 or higher
  mountOptions:
    - hard
    - nfsvers=4.1
    - retrans=2
    - rsize=1048576
    - wsize=1048576
  {{ end }}
  nfs:
    path: /
    server: {{ .Values.efs }}
