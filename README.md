# xilution-cms-penguin-infrastructure

## Prerequisites

1. Install [Terraform](https://www.terraform.io/)
1. Install [Helm](https://helm.sh/)

## Reference

* https://github.com/terraform-aws-modules/terraform-aws-eks
* https://aws.amazon.com/about-aws/whats-new/2019/09/amazon-eks-announces-beta-release-of-amazon-efs-csi-driver/

## To Init

```
make init
```

## To Verify

```
make verify
```


## Infrastructure

See: [Infrastructure Readme](./terraform/README.md)

## Deploy

See: [Deploy Readme](./helm/README.md)
