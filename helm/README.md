# Deploy

## To Verify

```
make verify
```

## To Provision

```
export XILUTION_ENVIRONMENT={test|prod}
export XILUTION_AWS_PROFILE=xilution-$XILUTION_ENVIRONMENT
export XILUTION_AWS_REGION=us-east-1
export XILUTION_PENGUIN_INSTANCE_ID={xilution-penguin-instance-id}
```

```
cd helm
make clean
make init
make verify
make apply
```

## To Deprovision

```
cd helm
make clean
make init
make verify
make destroy
```
