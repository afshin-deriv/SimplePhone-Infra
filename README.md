# SimplePhone-Infra
Terraform for build EKS fargate infrastructure

## Set Environment variables and requirements

| Tool      | Version |
| --------- | ----------:|
| awscli    | ~> 2.7.1   |
| terraform | ~> v1.0.0  |
| helm      | ~> 3.0.0   |
| flux      | ~> 0.31.5  |

Export credentials as environment values:
```
export KUBE_CONFIG_PATH=~/.kube/config
export AWS_ACCESS_KEY_ID="xxxxxxx"
export AWS_SECRET_ACCESS_KEY="yyyyyyy"
export TF_VAR_DB_PASSWORD=<Secure Password for DB>

```

#### Edit `aws_region` and `aws_profile` in the `variables.tf` file

## Setup S3 Bucket for terraform storage backend
```sh
git clone git@github.com:afshinpaydar-binary/SimplePhone-Infra.git
cd SimplePhone-Infra/terraform/s3_terraform_state/
terraform init
terraform plan -out .tfplan
terraform apply
```

## Setup Infra
```sh
cd SimplePhone-Infra/terraform/
terraform init -reconfigure
terraform plan -out .tfplan
terraform apply ".tfplan"
```

## Setup DB Secret
Replace <SECURE-DB-PASSWORD> with value of <TF_VAR_DB_PASSWORD> environment variable, and replace <DB_ENDPOINT> with output of previous command <rds_end_point>.
Also replace <API_SECRET_KEY> with a secure password.

Linux:
```
cd SimplePhone-Infra
echo -n "SECURE-DB-PASSWORD" | base64 | xargs -I {}  sed -i 's/db_password/{}/g' k8s/secret.yaml
echo -n "DB_ENDPOINT" | base64 | xargs -I {}  sed -i 's/db-endpoint/{}/g' k8s/secret.yaml
kubectl apply -f ./k8s/secret.yaml
echo -n "API_SECRET_KEY" | base64 | xargs -I {}  sed -i 's/api-secret-key/{}/g' k8s/secret.yaml
kubectl apply -f ./k8s/secret.yaml
```

Mac OS:
```
cd SimplePhone-Infra
echo -n "SECURE-DB-PASSWORD" | base64 | xargs -I {}  gsed -i 's/db_password/{}/g' ./k8s/secret.yaml
echo -n "DB_ENDPOINT" | base64 | xargs -I {}  gsed -i 's/db-endpoint/{}/g' ./k8s/secret.yaml
echo -n "API_SECRET_KEY" | base64 | xargs -I {}  gsed -i 's/api-secret-key/{}/g' ./k8s/secret.yaml
kubectl apply -f ./k8s/secret.yaml
```
## Create Ingres 
```sh
cd SimplePhone-Infra
kubectl apply -f ./k8s/ingress.yaml
```

## Configure Https and Certificate
Create a managed Certificate by AWS Certificate Manager and update value of `alb.ingress.kubernetes.io/certificate-arn` annotation in the `./flux/ingress.yaml` file.

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
$ kubectl delete -f ../flux/
# Go to specific resource folder (eks, kms, mysql)
$ terraform refresh
$ terraform destroy
$ aws s3 rm s3://terraform-simplephone --recursive
```