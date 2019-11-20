include ./config.mk

clean-test:
	aws s3 rm s3://$(PRODUCT_NAME)-data-test --recursive --profile xilution-test

clean-prod:
	aws s3 rm s3://$(PRODUCT_NAME)-data-prod --recursive --profile xilution-prod

build:
	@echo "nothing to build"

deploy-prod:
	aws s3 cp s3://$(PRODUCT_NAME)-data-test s3://$(PRODUCT_NAME)-data-prod \
		--recursive \
		--profile xilution-prod

deploy-test:
	aws s3 cp . s3://$(PRODUCT_NAME)-data-test \
		--exclude ".git/*" \
		--exclude ".idea/*" \
		--exclude ".DS_Store" \
		--exclude "dev-ops/*" \
		--exclude "output-build/*.yaml" \
		--exclude "output-infrastructure/*.yaml" \
		--exclude "terraform/.terraform/*" \
		--exclude "terraform/.gitignore" \
		--exclude "terraform/README.md" \
		--exclude "helm/README.md" \
		--exclude ".gitignore" \
		--exclude "config.mk" \
		--exclude "Makefile" \
		--exclude "README.md" \
		--recursive \
    	--profile xilution-test

deprovision-prod:
	aws cloudformation delete-stack --stack-name $(PRODUCT_NAME)-s3 --profile xilution-prod
	aws cloudformation delete-stack --stack-name $(PRODUCT_NAME)-terraform --profile xilution-prod

deprovision-test:
	aws cloudformation delete-stack --stack-name $(PRODUCT_NAME)-s3 --profile xilution-test
	aws cloudformation delete-stack --stack-name $(PRODUCT_NAME)-terraform --profile xilution-test

provision-prod:
	aws cloudformation create-stack --stack-name $(PRODUCT_NAME)-s3 \
		--template-body file://./dev-ops/aws/cloud-formation/common-s3.yaml \
		--parameters ParameterKey=ProductName,ParameterValue=$(PRODUCT_NAME) \
					 ParameterKey=Environment,ParameterValue=prod \
		--profile xilution-prod
	aws cloudformation create-stack --stack-name $(PRODUCT_NAME)-terraform \
		--template-body file://./dev-ops/aws/cloud-formation/common-terraform.yaml \
		--parameters ParameterKey=ProductName,ParameterValue=$(PRODUCT_NAME) \
					 ParameterKey=Environment,ParameterValue=prod \
		--profile xilution-prod

provision-test:
	aws cloudformation create-stack --stack-name $(PRODUCT_NAME)-s3 \
		--template-body file://./dev-ops/aws/cloud-formation/common-s3.yaml \
		--parameters ParameterKey=ProductName,ParameterValue=$(PRODUCT_NAME) \
					 ParameterKey=Environment,ParameterValue=test \
		--profile xilution-test
	aws cloudformation create-stack --stack-name $(PRODUCT_NAME)-terraform \
		--template-body file://./dev-ops/aws/cloud-formation/common-terraform.yaml \
		--parameters ParameterKey=ProductName,ParameterValue=$(PRODUCT_NAME) \
					 ParameterKey=Environment,ParameterValue=test \
		--profile xilution-test

reprovision-prod:
	aws cloudformation update-stack --stack-name $(PRODUCT_NAME)-s3 \
		--template-body file://./dev-ops/aws/cloud-formation/common-s3.yaml \
		--parameters ParameterKey=ProductName,ParameterValue=$(PRODUCT_NAME) \
					 ParameterKey=Environment,ParameterValue=prod \
		--profile xilution-prod
	aws cloudformation update-stack --stack-name $(PRODUCT_NAME)-terraform \
		--template-body file://./dev-ops/aws/cloud-formation/common-terraform.yaml \
		--parameters ParameterKey=ProductName,ParameterValue=$(PRODUCT_NAME) \
					 ParameterKey=Environment,ParameterValue=prod \
		--profile xilution-prod

reprovision-test:
	aws cloudformation update-stack --stack-name $(PRODUCT_NAME)-s3 \
		--template-body file://./dev-ops/aws/cloud-formation/common-s3.yaml \
		--parameters ParameterKey=ProductName,ParameterValue=$(PRODUCT_NAME) \
					 ParameterKey=Environment,ParameterValue=test \
		--profile xilution-test
	aws cloudformation update-stack --stack-name $(PRODUCT_NAME)-terraform \
		--template-body file://./dev-ops/aws/cloud-formation/common-terraform.yaml \
		--parameters ParameterKey=ProductName,ParameterValue=$(PRODUCT_NAME) \
					 ParameterKey=Environment,ParameterValue=test \
		--profile xilution-test

verify:
	aws cloudformation validate-template --template-body file://./dev-ops/aws/cloud-formation/common-s3.yaml
	aws cloudformation validate-template --template-body file://./dev-ops/aws/cloud-formation/common-terraform.yaml
