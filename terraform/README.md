# Infrastructure

## To Verify

```
make verify
```

## To Provision

```
cd terraform
make verify
make clean
make init
make apply-{test|prod}
make init-{test|prod}
make output
```

## To Deprovision

```
cd terraform
make destroy-{test|prod}
```
