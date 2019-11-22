include ../config.mk
include ./config.mk

clean:
	rm -rf .terraform

refresh:
	terraform refresh \
		-var="organization_id=$(XILUTION_ORGANIZATION_ID)" \
		-var="profile=$(XILUTION_AWS_PROFILE)"

plan:
	terraform plan \
		-var="organization_id=$(XILUTION_ORGANIZATION_ID)" \
		-var="profile=$(XILUTION_AWS_PROFILE)"

apply:
	terraform apply \
		-var="organization_id=$(XILUTION_ORGANIZATION_ID)" \
		-var="profile=$(XILUTION_AWS_PROFILE)" \
		-auto-approve

destroy:
	terraform destroy \
		-var="organization_id=$(XILUTION_ORGANIZATION_ID)" \
		-var="profile=$(XILUTION_AWS_PROFILE)" \
		-auto-approve

configure-k8s:
	../scripts/update-kubeconfig.sh $(XILUTION_AWS_REGION) $(XILUTION_AWS_PROFILE)
	kubectl apply -f config-map-aws-auth_xilution-k8s.yaml
	rm -rf config-map-aws-auth_xilution-k8s.yaml
	kubectl create namespace monitoring | true
	kubectl create namespace tiller | true
	kubectl create namespace wordpress | true
	./scripts/install-efs-csi-driver.sh
	./scripts/install-efs-persistent-volume.sh
	./scripts/install-metrics-server.sh
	./scripts/install-kubernetes-dashboard.sh
	../scripts/start-tiller.sh
	./scripts/install-grafana.sh
	./scripts/install-prometheus.sh
	../scripts/stop-tiller.sh
	./scripts/install-db-secret.sh $(WORDPRESS_DB_PASSWORD)
	./scripts/install-db-config-map.sh
	./scripts/install-wp-persistent-volumn-claim.sh

init:
	chmod u+x ./scripts/*.sh
	terraform init \
		-backend-config="key=$(XILUTION_ORGANIZATION_ID)/terraform.tfstate" \
		-backend-config="bucket=xilution-cms-penguin-infrastructure-terraform-backend-$(XILUTION_ENVIRONMENT)" \
		-backend-config="dynamodb_table=xilution-cms-penguin-infrastructure-terraform-backend-lock" \
		-backend-config="region=$(XILUTION_AWS_REGION)" \
		-backend-config="profile=$(XILUTION_AWS_PROFILE)"

verify:
	terraform validate
