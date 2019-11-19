include ../config.mk

clean:
	rm -rf .terraform

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
	aws eks update-kubeconfig \
		--region us-east-1 \
		--name xilution-k8s \
		--profile xilution-prod
	kubectl apply -f config-map-aws-auth_xilution-k8s.yaml

init-test:
	aws eks update-kubeconfig \
		--region us-east-1 \
		--name xilution-k8s \
		--profile xilution-test
	kubectl apply -f config-map-aws-auth_xilution-k8s.yaml

output:
	terraform output -json | jq '. | { database: { host: .db_host.value } }' > ../output/database.json
	yq r ../output/database.json > ../output/database.yaml
	rm -rf ../output/database.json

init:
	terraform init -backend-config="key=path/to/state"

verify:
	terraform validate
