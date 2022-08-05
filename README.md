# SimplePhone-Infra
Terraform for build EKS fargate infrastructure

## Set Environment variables and requirements

| Tool      | Version |
| --------- | ----------:|
| awscli    | ~> 2.7.1   |
| terraform | ~> v1.0.0  |
| helm      | ~> 3.0.0   |
| flux      | ~> 0.31.5  |

```
export KUBE_CONFIG_PATH=~/.kube/config
export AWS_ACCESS_KEY_ID="xxxxxxx"
export AWS_SECRET_ACCESS_KEY="yyyyyyy"
export TF_VAR_DB_PASSWORD=111222333
git clone git@github.com:afshinpaydar-binary/SimplePhone-Infra.git
```

#### Edit `aws_region` and `aws_profile` in the `variables.tf` file

## Setup S3 Bucket for terraform storage backend
```
$ cd SimplePhone-Infra/terraform/s3_terraform_state/
$ terraform init
$ terraform plan -out .tfplan
$ terraform apply
```

## Setup Infra
```
$ cd SimplePhone-Infra/terraform/
$ terraform init -reconfigure
$ terraform plan -out .tfplan
$ terraform apply ".tfplan"
```

## Setup DB Secret
Replace <secure-db-password> with <TF_VAR_DB_PASSWORD> value, used to connect to RDS.

Linux:
```
echo -n "secure-db-password" | base64 | xargs -I {}  sed -i 's/db_password/{}/g' k8s/secret.yaml
kubectl apply -f ./k8s/secret.yaml
```

Mac:
```
echo -n "secure-db-password" | base64 | xargs -I {}  gsed -i 's/db_password/{}/g' k8s/secret.yaml
kubectl apply -f ./k8s/secret.yaml
```


## Setup CD (flux bootstrap)

1. Bootstrap the Flux Config Repository:

For Personal Accounts:
```
flux bootstrap github \
  --owner=$GITHUB_USER \
  --repository=flux-deploy \
  --branch=main \
  --path=./clusters/cluster1 \
  --personal
```

For Organizational Accounts:
```
flux bootstrap github \
  --owner=$GITHUB_USER \
  --repository=flux-deploy \
  --branch=main \
  --path=./clusters/cluster1
```

2. Create a Source to Point Flux to the Desired State
```
flux create source git simplephone \
  --url=https://github.com/afshinpaydar-binary/SimplePhone-Infra.git \
  --branch=main \
  --interval=30s \
  --export > ./clusters/cluster1/deployment.yaml
```

3.  Create a Kustomization to Deploy the Desired State Found in the Source
```
flux create kustomization simplephone \
  --source=simplephone \
  --path=./flux \
  --prune=true \
  --validation=client \
  --interval=1m \
  --export > ./clusters/cluster1/deployment-kustomization.yaml
```

4.  Watch the Kustomization
```
watch flux get kustomizations
```

## Get access and check the status
```
$ kubectl get ing -n production
Create a CNAME that ponits <Site DNS > to <LB DNS - output of previous command>
$ kubectl get svc -n production
$ helm list -n kube-system
$ kubectl logs -f -n kube-system \
  -l app.kubernetes.io/name=aws-loadbalancer-controller
$ curl $(kubectl get ing -n production -o jsonpath='{.items[0].status.loadBalancer.ingress[0].hostname}')
```

## Tearing down
```
$ kubectl delete -f ../k8s/
# Go to specific resource folder (eks, kms, mysql)
$ terraform refresh
$ terraform destroy
$ aws s3 rm s3://terraform-simplephone --recursive
```