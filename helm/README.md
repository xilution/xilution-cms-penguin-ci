# Deploy

## To Verify

```
make verify
```

## To Provision

```
cd helm
make init-{test|prod}
make wordpress-release
```

## To Deprovision

```
cd helm
make wordpress-delete
```


