include ./config.mk

clean:
	rm -rf .terraform *.tfstate*

clean-test:
	aws s3 rm s3://$(PRODUCT_NAME)-data-test --recursive --profile xilution-test

clean-prod:
	aws s3 rm s3://$(PRODUCT_NAME)-data-prod --recursive --profile xilution-prod

k8s-diff:
	kubectl diff -k ./k8s

k8s-apply:
	kubectl apply -k ./k8s

k8s-delete:
	kubectl delete -k ./k8s

cluster-plan:
	terraform plan \
		-var="organization_id=$(XILUTION_ORGANIZATION_ID)" \
		./terraform/cluster

cluster-apply:
	terraform apply \
		-var="organization_id=$(XILUTION_ORGANIZATION_ID)" \
		./terraform/cluster

cluster-destroy:
	terraform destroy \
		-var="organization_id=$(XILUTION_ORGANIZATION_ID)" \
		./terraform/cluster

cluster-init:
	aws eks update-kubeconfig \
		--region us-east-1 \
		--name xilution-k8s \
		--profile xilution-prod
	kubectl apply -f config-map-aws-auth_xilution-k8s.yaml

build:
	@echo "nothing to do"

deploy-prod:
	aws s3 cp s3://$(PRODUCT_NAME)-data-test s3://$(PRODUCT_NAME)-data-prod \
		--recursive \
		--profile xilution-prod

deploy-test:
	aws s3 cp . s3://$(PRODUCT_NAME)-data-test \
		--exclude ".git/*" \
		--exclude ".idea/*" \
		--exclude ".terraform/*" \
		--exclude "dev-ops/*" \
		--exclude "k8s/.gitignore" \
		--exclude "k8s/kustomization.yaml" \
		--exclude "terraform/cluster/.terraform/*" \
		--exclude "terraform/cluster/.gitignore" \
		--exclude ".gitignore" \
		--exclude "config.mk" \
		--exclude "makefile" \
		--exclude "README.md" \
		--recursive \
    	--profile xilution-test

deprovision-prod:
	aws cloudformation delete-stack --stack-name $(PRODUCT_NAME)-s3 --profile xilution-prod

deprovision-test:
	aws cloudformation delete-stack --stack-name $(PRODUCT_NAME)-s3 --profile xilution-test

init:
	terraform init ./terraform/cluster

provision-prod:
	aws cloudformation create-stack --stack-name $(PRODUCT_NAME)-s3 \
		--template-body file://./dev-ops/aws/cloud-formation/common-s3.yaml \
		--parameters ParameterKey=ProductName,ParameterValue=$(PRODUCT_NAME) \
					 ParameterKey=Environment,ParameterValue=prod \
		--profile xilution-prod

provision-test:
	aws cloudformation create-stack --stack-name $(PRODUCT_NAME)-s3 \
		--template-body file://./dev-ops/aws/cloud-formation/common-s3.yaml \
		--parameters ParameterKey=ProductName,ParameterValue=$(PRODUCT_NAME) \
					 ParameterKey=Environment,ParameterValue=test \
		--profile xilution-test

reprovision-prod:
	aws cloudformation update-stack --stack-name $(PRODUCT_NAME)-s3 \
		--template-body file://./dev-ops/aws/cloud-formation/common-s3.yaml \
		--parameters ParameterKey=ProductName,ParameterValue=$(PRODUCT_NAME) \
					 ParameterKey=Environment,ParameterValue=prod \
		--profile xilution-prod

reprovision-test:
	aws cloudformation update-stack --stack-name $(PRODUCT_NAME)-s3 \
		--template-body file://./dev-ops/aws/cloud-formation/common-s3.yaml \
		--parameters ParameterKey=ProductName,ParameterValue=$(PRODUCT_NAME) \
					 ParameterKey=Environment,ParameterValue=test \
		--profile xilution-test

verify:
	aws cloudformation validate-template --template-body file://./dev-ops/aws/cloud-formation/common-s3.yaml
	terraform validate ./terraform
	kubeval ./k8s/mysql-deployment.yaml ./k8s/wordpress-deployment.yaml
