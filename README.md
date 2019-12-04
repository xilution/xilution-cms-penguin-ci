# xilution-cms-penguin-infrastructure

## Prerequisites

1. Install [Terraform](https://www.terraform.io/)
1. Install [Helm](https://helm.sh/)

## Reference

* https://github.com/terraform-aws-modules/terraform-aws-eks
* https://aws.amazon.com/about-aws/whats-new/2019/09/amazon-eks-announces-beta-release-of-amazon-efs-csi-driver/

## Build the CodeBuild Image

```
git clone https://github.com/xilution/xilution-codebuild-docker-images.git
cd xilution-codebuild-docker-images
make build-standard-2.0
```

## Initialize this Repo

```
make submodules
make init
```

## To Verify

Run `make init && make verify`

## To Test Pipeline Deploy Step

Run `make test-pipeline-build`

## To Test Pipeline Infrastructure Step

Run `make test-pipeline-infrastructure`

## To Test Pipeline Deploy Step

Run `make test-pipeline-deploy`

## To Uninstall Word Press from the K8s Cluster

Run `make uninstall-wordpress`

## To Uninstall the K8s Cluster

Run `make infrastructure-destroy`

## Update the Kubectl Config

Run `aws eks update-kubeconfig --name xilution-k8s`

## Run the Kubernetes Dashboard

```
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep eks-admin | awk '{print $1}')
kubectl proxy
```

```
open http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login
```
