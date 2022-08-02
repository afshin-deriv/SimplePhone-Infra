# SimplePhone-Infra
Terraform for build EKS fargate infrastructure

## Deploy
Install `awscli ~> 2.7.1`
```
export KUBE_CONFIG_PATH=~/.kube/config

$ git clone git@github.com:afshinpaydar-binary/SimplePhone-Infra.git
$ cd SimplePhone-Infra/eks
## Edit `aws_region` and `aws_profile` on `variables.tf` file
$ terraform init
$ terraform plan
$ terraform apply
$ kubectl apply -f ../k8s/deployment.yaml && kubectl apply -f ../k8s/
```

## Access and status
```
$ kubectl get svc -n production
$ curl $(kubectl get services -o jsonpath='{.items[1].spec.externalIP}')
```

## Tearing down
```
$ kubectl delete -f ./k8s/
$ terraform refresh
$ terraform destroy
```