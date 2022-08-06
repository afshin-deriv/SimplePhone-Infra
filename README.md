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
Replace <SECURE-DB-PASSWORD> with value of <TF_VAR_DB_PASSWORD> environment variable, and replace <DB_ENDPOINT> with output of previous command <rds_end_point>.
Also replace <API_SECRET_KEY> with a secure password.

Linux:
```
echo -n "SECURE-DB-PASSWORD" | base64 | xargs -I {}  sed -i 's/db_password/{}/g' k8s/secret.yaml
echo -n "DB_ENDPOINT" | base64 | xargs -I {}  sed -i 's/db-endpoint/{}/g' k8s/secret.yaml
kubectl apply -f ./k8s/secret.yaml
echo -n "API_SECRET_KEY" | base64 | xargs -I {}  sed -i 's/api-secret-key /{}/g' k8s/secret.yaml
kubectl apply -f ./k8s/secret.yaml
```

Mac OS:
```
echo -n "SECURE-DB-PASSWORD" | base64 | xargs -I {}  gsed -i 's/db_password/{}/g' k8s/secret.yaml
echo -n "DB_ENDPOINT" | base64 | xargs -I {}  gsed -i 's/db-endpoint/{}/g' k8s/secret.yaml
echo -n "API_SECRET_KEY" | base64 | xargs -I {}  gsed -i 's/api-secret-key /{}/g' k8s/secret.yaml
kubectl apply -f ./k8s/secret.yaml
```

## Configure Https and Certificate
Create a managed Certificate by AWS Certificate Manager and update value of `alb.ingress.kubernetes.io/certificate-arn` annotation in the `./flux/ingress.yaml` file.

## Setup CD (flux bootstrap)
Flux keeps Kubernetes clusters in sync with configuration kept under source control like Git repositories, and automates updates to that configuration when there is new code to deploy. It is built using Kubernetes' API extension server, and can integrate with Prometheus and other core components of the Kubernetes ecosystem. Flux supports multi-tenancy and syncs an arbitrary number of Git repositories.

In this section, we’ll set up Flux to synchronize changes in the SimplePhone-Infra repository. This example is a very simple pipeline that demonstrates how to sync one application repo to a single cluster, but as mentioned, Flux is capable of a lot more than that.

1. For MacOS users, you can install flux with Homebrew:

`brew install fluxcd/tap/flux`

For other installation options, see [Installing the Flux CLI](https://toolkit.fluxcd.io/get-started/#install-the-flux-cli).

2. Once installed, check that your EKS cluster satisfies the prerequisites:

`flux check --pre`

If successful, it returns something similar to this:
```
► checking prerequisites
✔ Kubernetes 1.22.0 >=1.20.6-0
✔ prerequisites checks passed
```

Flux supports synchronizing manifests in a single directory, but when you have a lot of YAML it is more efficient to use Kustomize to manage them. For the SimplePhone example, all of the manifests were copied into a deploy directory and a kustomization file was added.  For this example, the kustomization file contains a `newTag` directive for the simplephone images section:

```
images:
- name: simplephone
  newName:simplephone
  newTag: new
```
As mentioned above, the Github Actions script updates the image tag in this file after the image is built and pushed, indicating to Flux that a new image is available in Docker Hub.

1. Bootstrap the Flux Config Repository:

```
export GITHUB_TOKEN=<personal_access_token>
export GITHUB_USER=<github_username>
export GITHUB_REPO=SimplePhone-deploy

flux bootstrap github \
    --owner="${GITHUB_USER}" \
    --repository="${GITHUB_REPO}" \
    --private=false \
    --path=./clusters/cluster1 \
    --personal \
    --token-auth
```

2. Create a secret
```
flux create secret git simplephone-flux-secret \
    --url=ssh://git@github.com/${GITHUB_USER}/${GITHUB_REPO}
```

3. Add Deploy key
```
kubectl get secret simplephone-flux-secret -n flux-system -ojson \
    | jq -r '.data."identity.pub"' | base64 -d
```

4. Create a source

```
git clone git@github.com:afshinpaydar-binary/SimplePhone-deploy.git
cd SimplePhone-deploy

flux create source git simplephone \
    --url=ssh://git@github.com/${GITHUB_USER}/${GITHUB_REPO} \
    --secret-ref simplephone-flux-secret \
    --branch=main \
    --export > ./clusters/cluster1/simplephone-flux-source.yaml

# verify
flux get source git
cat ./clusters/cluster1/simplephone-flux-source.yaml
```

```
flux create kustomization simplephone \
  --source=simplephone \
  --path=./flux \
  --prune=true \
  --interval=1m \
  --export > ./clusters/cluster1/simplephone-kustomization.yaml

git add ./clusters/cluster1/simplephone-flux-source.yaml ./clusters/cluster1/simplephone-kustomization.yaml
git commit -m "add simplephone source"
git push origin main

flux reconcile source git simplephone

# verify
watch kubectl get -n flux-system gitrepositories

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
$ kubectl delete -f ../flux/
# Go to specific resource folder (eks, kms, mysql)
$ terraform refresh
$ terraform destroy
$ aws s3 rm s3://terraform-simplephone --recursive
```