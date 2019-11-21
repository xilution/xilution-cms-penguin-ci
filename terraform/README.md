# Infrastructure

## To Verify

```
make verify
```

## To Provision

```
export XILUTION_ENVIRONMENT={test|prod}
export XILUTION_AWS_PROFILE=xilution-$XILUTION_ENVIRONMENT
export XILUTION_ORGANIZATION_ID={xilution-organization-or-sub-organization-id}
```

```
cd terraform
make clean
make init
make verify
make set-up
make apply
make output
make configure-k8s
make tear-down
```

## To Deprovision

```
cd terraform
make clean
make init
make verify
make set-up
make destroy
make tear-down
```
