# Deploy

## To Verify

```
make verify
```

## To Provision

```
export XILUTION_AWS_PROFILE={xilution-(test|prod)}
export XILUTION_PENGUIN_INSTANCE_ID={xilution-penguin-instance-id}
```

```
cd helm
make clean
make init
make verify
make release-wordpress
```

## To Deprovision

```
cd helm
make clean
make init
make verify
make delete-wordpress
```


