# xilution-cms-penguin-infrastructure

## Prerequisites

1. Install [Terraform](https://www.terraform.io/)
1. Install [Helm](https://helm.sh/)
1. The following environment variables need to be in scope.
    ```
    export XILUTION_ORGANIZATION_ID={Xilution Organization or Sub-organization ID}
    export CLIENT_AWS_ACCOUNT={Client AWS Account ID}
    export CLIENT_AWS_REGION={Client AWS Region}
    export K8S_CLUSTER_NAME=xilution-k8s
    export XILUTION_PENGUIN_INSTANCE_ID=09834225195643a9852d6e39b770712c
    export WORDPRESS_DB_USERNAME=wordpress
    export WORDPRESS_DB_PASSWORD=$(echo -n 'wordpress' | base64)
    ```

    Check the values
    ```
    echo $XILUTION_ORGANIZATION_ID
    echo $CLIENT_AWS_ACCOUNT
    echo $CLIENT_AWS_REGION
    echo $K8S_CLUSTER_NAME
    echo $XILUTION_PENGUIN_INSTANCE_ID
    echo $WORDPRESS_DB_USERNAME
    echo $WORDPRESS_DB_PASSWORD
    ```

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

## To Test Pipeline Build Step

Run `make test-pipeline-build`

## To Test Pipeline Infrastructure Step

Run `make test-pipeline-infrastructure`

## To Test Pipeline Deploy Step

Run `make test-pipeline-deploy`

## To Uninstall Word Press from the K8s Cluster

Run `make uninstall-wordpress`

## To Uninstall the infrastructure

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
