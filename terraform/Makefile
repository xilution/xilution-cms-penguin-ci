include ../config.mk
include ./config.mk

clean:
	rm -rf .terraform
	rm -rf ../output-infrastructure/*.yaml

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
	aws eks update-kubeconfig --region $(XILUTION_AWS_REGION) --name xilution-k8s --profile $(XILUTION_AWS_PROFILE)
	kubectl apply -f config-map-aws-auth_xilution-k8s.yaml
	kubectl apply -k "github.com/kubernetes-sigs/aws-efs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"

output:
	terraform output -json | jq '. | { mysql: { host: .db_host.value } }' > ../output-infrastructure/aurora.json
	yq r ../output-infrastructure/aurora.json > ../output-infrastructure/aurora.yaml
	rm -rf ../output-infrastructure/aurora.json
	terraform output -json | jq '. | { efs : { fileSystemId: .efs_file_system_id.value } }' > ../output-infrastructure/efs.json
	yq r ../output-infrastructure/efs.json > ../output-infrastructure/efs.yaml
	rm -rf ../output-infrastructure/efs.json

init:
	terraform init \
		-backend-config="key=$(XILUTION_ORGANIZATION_ID)/terraform.tfstate" \
		-backend-config="bucket=xilution-cms-penguin-infrastructure-terraform-backend-$(XILUTION_ENVIRONMENT)" \
		-backend-config="dynamodb_table=xilution-cms-penguin-infrastructure-terraform-backend-lock" \
		-backend-config="region=$(XILUTION_AWS_REGION)" \
		-backend-config="profile=$(XILUTION_AWS_PROFILE)"

set-up:
	@echo "nothing to do"

tear-down:
	@echo "nothing to do"

verify:
	terraform validate
