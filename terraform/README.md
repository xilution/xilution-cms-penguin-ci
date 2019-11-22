# Infrastructure

## To Verify

```
make verify
```

## To Provision

```
export XILUTION_ENVIRONMENT={test|prod}
export XILUTION_AWS_PROFILE=xilution-$XILUTION_ENVIRONMENT
export XILUTION_ORGANIZATION_ID={xilution-organization-or-sub-organization-id}
export WORDPRESS_DB_PASSWORD=`echo -n 'wordpress' | base64`
```

```
cd terraform
make clean
make init
make verify
make apply
make configure-k8s
```

## To Deprovision

```
cd terraform
make clean
make init
make verify
make destroy
```

## To Connect to Kubernetes Dashboard

Get Token
```
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep eks-admin | awk '{print $1}')
```

Proxy (separate terminal)

```
kubectl proxy
```

Open Kubernetes Dashboard

```
open http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login
```

## To Connect to Prometheus

Port Forward (separate terminal)

```
export POD_NAME=$(kubectl get pods --namespace monitoring -l "app=prometheus,component=server" -o jsonpath="{.items[0].metadata.name}")
kubectl --namespace monitoring port-forward $POD_NAME 9090
```

Open Prometheus

```
open http://localhost:9090
```

## To Connect to Grafana

Get Password

```
kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```

Port Forward (separate terminal)

```
export POD_NAME=$(kubectl get pods --namespace monitoring -l "app=grafana" -o jsonpath="{.items[0].metadata.name}")
kubectl --namespace monitoring port-forward $POD_NAME 3000
```

Open Grafana

```
open http://localhost:3000
```
