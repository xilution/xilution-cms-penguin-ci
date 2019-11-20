# Deploy

## To Verify

```
make verify
```

## To Provision

```
cd helm
make clean
make init-{test|prod}
make release-wordpress
```

## To Deprovision

```
cd helm
make wordpress-delete
```


