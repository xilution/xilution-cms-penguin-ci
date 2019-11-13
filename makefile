include ./config.mk

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
		--exclude "terraform/.gitignore" \
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
	terraform init ./terraform

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
