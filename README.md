# SimplePhone-Infra
Terraform for build EKS fargate infrastructure

## Deploy
Install `awscli ~> 2.7.1`
```
$ export KUBE_CONFIG_PATH=~/.kube/config
$ git clone git@github.com:afshinpaydar-binary/SimplePhone-Infra.git
```

## Edit `aws_region` and `aws_profile` in the `variables.tf` file

# Setup S3 Bucket for terraform storage backend
```
$ cd SimplePhone-Infra/s3_terraform_state
$ terraform init
$ terraform plan
$ terraform apply
```

# Setup KMS
```
$ cd SimplePhone-Infra/kms
$ terraform init
$ terraform plan
$ terraform apply

$ echo -n '<Secure-Password-for-DB>' > /tmp/plaintext-password
# Replace <Key-ID> with previous `terraform apply` output `key_id` value
$ aws kms encrypt --region <AWS-Region> --key-id <Key-ID> --plaintext fileb:///tmp/plaintext-password --encryption-context usage=Database --output text --query CiphertextBlob
$ rm -rf /tmp/plaintext-password
# Update `aws_kms_secrets_payload` variablein the `variables.tf` file with output of last command
```

## Setup EKS
```
$ cd SimplePhone-Infra/eks
$ terraform init
$ terraform plan
$ terraform apply
```

## Setup K8S deployment
```
$ kubectl apply -f ../k8s/deployment.yaml && kubectl apply -f ../k8s/
$ kubectl get ing -n production
Create a CNAME that ponits <Site DNS> to <LB DNS>
```

## Get access and check the status
```
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
```