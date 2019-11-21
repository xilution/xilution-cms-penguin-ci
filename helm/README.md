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
make set-up
make release-wordpress
make tear-down
```

## To Deprovision

```
cd helm
make clean
make init
make verify
make set-up
make delete-wordpress
make tear-down
```


