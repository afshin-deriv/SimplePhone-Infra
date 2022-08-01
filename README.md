# SimplePhone-Infra
Terraform for build EKS fargate infrastructure

## Deploy

```
export KUBE_CONFIG_PATH=~/.kube/config

$ git clone git@github.com:afshinpaydar-binary/SimplePhone-Infra.git
$ cd SimplePhone-Infra/eks
## Edit `aws_region` and `aws_profile` on `eks/variables.tf` file
$ terraform init
$ terraform plan
$ terraform apply
```

## Tearing down
```
$ terraform destroy
```