# Deploy

## To Verify

```
make verify
```

## To Provision

```
cd helm
make verify
export XILUTION_PENGUIN_INSTANCE_ID=5f3a3e4255234706a6fae7db5f3983e1
make clean
make init-{test|prod}
make release-wordpress
```

## To Deprovision

```
cd helm
make wordpress-delete
```


