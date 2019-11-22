#!/bin/bash

WORDPRESS_DB_HOST=$(terraform output -json | jq -r '.db_host.value')

cat <<EOF >./config-map.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: mysql-config
  namespace: wordpress
data:
  host: ${WORDPRESS_DB_HOST}
  port: "3306"
  user: wordpress
EOF
kubectl apply -f config-map.yaml
rm -rf config-map.yaml
