# xilution-cms-penguin-ci

## Prerequisites

1. Clone `https://github.com/xilution/xilution-scripts` and add root directory to your PATH environment variable.
1. Install [Terraform](https://www.terraform.io/)
1. Install [Helm](https://helm.sh/)
1. The following environment variables need to be in scope.
    ```
    export XILUTION_ORGANIZATION_ID={Xilution Organization or Sub-organization ID}
    export CLIENT_AWS_ACCOUNT={Client AWS Account ID}
    export CLIENT_AWS_REGION={Client AWS Region}
    export K8S_CLUSTER_NAME=xilution-k8s
    export XILUTION_PENGUIN_INSTANCE_ID={Penguin Instance ID}
    
    ```

    Check the values
    ```
    echo $XILUTION_ORGANIZATION_ID
    echo $CLIENT_AWS_ACCOUNT
    echo $CLIENT_AWS_REGION
    echo $K8S_CLUSTER_NAME
    echo $XILUTION_PENGUIN_INSTANCE_ID
    
    ```

## Reference

* https://github.com/terraform-aws-modules/terraform-aws-eks
* https://aws.amazon.com/about-aws/whats-new/2019/09/amazon-eks-announces-beta-release-of-amazon-efs-csi-driver/

## To pull the CodeBuild docker image

Run `make pull-docker-image`

## To init the submodules

Run `make submodules-init`

## To updated the submodules

Run `make submodules-update`

## To access to a client's account

```
unset AWS_PROFILE
unset AWS_REGION
update-xilution-profile.sh $XILUTION_SHARED_ACCOUNT_ID $XILUTION_USER_ID $XILUTION_PROD_ACCOUNT_ID xilution-developer-role xilution-prod {mfa-code}
assume-client-role.sh $CLIENT_AWS_ACCOUNT xilution-developer-role xilution-prod client-profile
export AWS_PROFILE=client-profile
export AWS_REGION=$CLIENT_AWS_REGION
```

## Initialize terraform

Run `make init`

## Verify terraform

Run `make verify`

## To Test Pipeline Build Step

Run `make test-pipeline-build`

## To Test Pipeline Infrastructure Step

Run `make test-pipeline-infrastructure`

## To Test Pipeline Deploy Step

Run `make test-pipeline-deploy`

## To access a client's k8s cluster

Run `aws eks update-kubeconfig --name xilution-k8s` to update your local kubeconfig file.

## To Uninstall Word Press from the K8s Cluster

Run `make uninstall-wordpress`

## To Uninstall the infrastructure

Run `make infrastructure-destroy`
