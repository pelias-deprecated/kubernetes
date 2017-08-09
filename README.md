# Pelias Kubernetes Configuration

These are _extremely_ early stage Kubernetes configuration files for Pelias.

# minikube

by default minikube doesn't use all available CPUs and RAM, if you get messages such as `Insufficient memory` then you may need to restart minikube with higher resource limits:

```bash
$ minikube stop
$ minikube delete

# use all available CPU/RAM
#$ minikube start --cpus `nproc --all` --memory `free -m | awk '/^Mem:/{print $2}'`

# or select your own limits
$ minikube start --cpus 6 --memory 8192
```

see: https://github.com/kubernetes/minikube/issues/567

# jobs

if a job shows as `Status: Failed`, you can get more information by inspecting the pod:

```bash
$ kubectl get pods -n pelias-dev
NAME                         READY     STATUS     RESTARTS   AGE
elasticsearch-f69v2          1/1       Running    0          52m
openstreetmap-import-zwrwv   0/1       Init:0/1   0          1s
pelias-api-587096593-8f6rc   1/1       Running    0          52m

$ kubectl describe pod -n pelias-dev openstreetmap-import-zwrwv
```
