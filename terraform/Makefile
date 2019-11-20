include ../config.mk

clean:
	rm -rf .terraform
	rm -rf ../output-infrastructure/*.yaml

refresh-test:
	terraform refresh \
		-var="organization_id=$(XILUTION_ORGANIZATION_ID)" \
		-var="profile=xilution-test"

refresh-prod:
	terraform refresh \
		-var="organization_id=$(XILUTION_ORGANIZATION_ID)" \
		-var="profile=xilution-prod"

plan-prod:
	terraform plan \
		-var="organization_id=$(XILUTION_ORGANIZATION_ID)" \
		-var="profile=xilution-prod"

plan-test:
	terraform plan \
		-var="organization_id=$(XILUTION_ORGANIZATION_ID)" \
		-var="profile=xilution-test"

apply-prod:
	terraform apply \
		-var="organization_id=$(XILUTION_ORGANIZATION_ID)" \
		-var="profile=xilution-prod" \
		-auto-approve

apply-test:
	terraform apply \
		-var="organization_id=$(XILUTION_ORGANIZATION_ID)" \
		-var="profile=xilution-test" \
		-auto-approve

destroy-prod:
	terraform destroy \
		-var="organization_id=$(XILUTION_ORGANIZATION_ID)" \
		-var="profile=xilution-prod" \
		-auto-approve

destroy-test:
	terraform destroy \
		-var="organization_id=$(XILUTION_ORGANIZATION_ID)" \
		-var="profile=xilution-test" \
		-auto-approve

init-prod:
	aws eks update-kubeconfig --region us-east-1 --name xilution-k8s --profile xilution-prod
	kubectl apply -f config-map-aws-auth_xilution-k8s.yaml
	kubectl apply -k "github.com/kubernetes-sigs/aws-efs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"

init-test:
	aws eks update-kubeconfig --region us-east-1 --name xilution-k8s --profile xilution-test
	kubectl apply -f config-map-aws-auth_xilution-k8s.yaml
	kubectl apply -k "github.com/kubernetes-sigs/aws-efs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"

output:
	terraform output -json | jq '. | { mysql: { host: .db_host.value } }' > ../output-infrastructure/aurora.json
	yq r ../output-infrastructure/aurora.json > ../output-infrastructure/aurora.yaml
	rm -rf ../output-infrastructure/aurora.json
	terraform output-infrastructure -json | jq '. | { efs : { fileSystemId: .efs_file_system_id.value } }' > ../output-infrastructure/efs.json
	yq r ../output-infrastructure/efs.json > ../output-infrastructure/efs.yaml
	rm -rf ../output-infrastructure/efs.json

init:
	terraform init -backend-config="key=$(XILUTION_ORGANIZATION_ID)/terraform.tfstate"

verify:
	terraform validate
