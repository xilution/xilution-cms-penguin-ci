# xilution-cms-penguin-ci

## Prerequisites

1. Clone `https://github.com/xilution/xilution-scripts` and add root directory to your PATH environment variable.
1. Install [Terraform](https://www.terraform.io/)
1. Install [Helm](https://helm.sh/)
1. The following environment variables need to be in scope.
    ```
    export XILUTION_ORGANIZATION_ID={Xilution Organization or Sub-organization ID}
    export PENGUIN_PIPELINE_ID={Penguin Pipeline ID}
    export GIRAFFE_PIPELINE_ID={Giraffe Pipeline ID}
    export XILUTION_AWS_ACCOUNT=$AWS_PROD_ACCOUNT_ID
    export XILUTION_AWS_REGION=us-east-1
    export XILUTION_ENVIRONMENT=prod
    export CLIENT_AWS_ACCOUNT={Client AWS Account ID}
    export CLIENT_AWS_REGION=us-east-1
    export STAGE_NAME={Stage Name (lower case)}
    export K8S_CLUSTER_NAME={Kubernetes Cluster Name. Ex: xilution-giraffe-eb78c776}
    
    ```

    Check the values
    ```
    echo $XILUTION_ORGANIZATION_ID
    echo $PENGUIN_PIPELINE_ID
    echo $GIRAFFE_PIPELINE_ID
    echo $XILUTION_AWS_ACCOUNT
    echo $XILUTION_AWS_REGION
    echo $XILUTION_ENVIRONMENT
    echo $CLIENT_AWS_ACCOUNT
    echo $CLIENT_AWS_REGION
    echo $STAGE_NAME
    echo $K8S_CLUSTER_NAME
    
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
update-xilution-mfa-profile.sh $AWS_SHARED_ACCOUNT_ID $AWS_USER_ID {mfa-code}
assume-client-role.sh $AWS_PROD_ACCOUNT_ID $CLIENT_AWS_ACCOUNT xilution-developer-role xilution-developer-role xilution-prod client-profile
aws sts get-caller-identity --profile client-profile
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

Run `aws eks update-kubeconfig --name $K8S_CLUSTER_NAME` to update your local kubeconfig file.

## To connect to a client's Kubernetes Dashboard

Reference: https://docs.aws.amazon.com/eks/latest/userguide/dashboard-tutorial.html

* Run `kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep eks-admin | awk '{print $1}')` to retrieve the authentication token.
* Run `kubectl proxy` to start a kubectl proxy.
    * Type `ctrl-c` to stop the kubectl proxy.
* To access the dashboard endpoint, open the following link with a web browser: `http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login`.

## To Uninstall Word Press from the K8s Cluster

Update kubconfig before running the following...

Run `./support/uninstall-wordpress.sh`

## To Uninstall the infrastructure

Run `./support/destroy-infrastructure.sh`
