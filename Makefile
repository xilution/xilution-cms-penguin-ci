clean:
	rm -rf .terraform properties.txt

build:
	@echo "nothing to build"

infrastructure-plan:
	terraform plan \
		-var="organization_id=$(XILUTION_ORGANIZATION_ID)" \
		-var="client_aws_account=$(CLIENT_AWS_ACCOUNT)"

infrastructure-destroy:
	terraform destroy \
		-var="organization_id=$(XILUTION_ORGANIZATION_ID)" \
		-var="client_aws_account=$(CLIENT_AWS_ACCOUNT)" \
		-auto-approve

uninstall-wordpress:
	helm tiller run tiller -- helm delete wordpress-$(XILUTION_PENGUIN_INSTANCE_ID)
	helm tiller run tiller -- helm del --purge wordpress-$(XILUTION_PENGUIN_INSTANCE_ID)

init:
	terraform init \
		-backend-config="key=xilution-cms-penguin/$(XILUTION_PENGUIN_INSTANCE_ID)/terraform.tfstate" \
		-backend-config="bucket=xilution-terraform-backend-state-bucket-$(CLIENT_AWS_ACCOUNT)" \
		-backend-config="dynamodb_table=xilution-terraform-backend-lock-table" \
		-var="client_aws_account=$(CLIENT_AWS_ACCOUNT)"

submodules-init:
	git submodule update --init

submodules-update:
	git submodule update --remote

verify:
	terraform validate

pull-docker-image:
	aws ecr get-login --no-include-email --profile=xilution-prod | /bin/bash
	docker pull $(XILUTION_PROD_ACCOUNT_ID).dkr.ecr.us-east-1.amazonaws.com/xilution/codebuild/standard-2.0:latest

test-pipeline-build:
	echo "XILUTION_ORGANIZATION_ID=$(XILUTION_ORGANIZATION_ID)\nCLIENT_AWS_ACCOUNT=$(CLIENT_AWS_ACCOUNT)\nCLIENT_AWS_REGION=$(CLIENT_AWS_REGION)" > ./properties.txt
	/bin/bash ./aws-codebuild-docker-images/local_builds/codebuild_build.sh \
		-i $(XILUTION_PROD_ACCOUNT_ID).dkr.ecr.us-east-1.amazonaws.com/xilution/codebuild/standard-2.0:latest \
		-p client-profile \
		-a ./output/build \
		-b /codebuild/output/srcDownload/secSrc/buildspecs/buildspec.yaml \
		-c \
		-e ./properties.txt \
		-s . \
		-s SourceCode:./xilution-wordpress-docker \
		-s buildspecs:./buildspecs/build
	rm -rf ./properties.txt

test-pipeline-infrastructure:
	echo "XILUTION_ORGANIZATION_ID=$(XILUTION_ORGANIZATION_ID)\nCLIENT_AWS_ACCOUNT=$(CLIENT_AWS_ACCOUNT)\nXILUTION_PENGUIN_INSTANCE_ID=$(XILUTION_PENGUIN_INSTANCE_ID)" > ./properties.txt
	/bin/bash ./aws-codebuild-docker-images/local_builds/codebuild_build.sh \
		-i $(XILUTION_PROD_ACCOUNT_ID).dkr.ecr.us-east-1.amazonaws.com/xilution/codebuild/standard-2.0:latest \
		-p client-profile \
		-a ./output/infrastructure \
		-b /codebuild/output/srcDownload/secSrc/buildspecs/buildspec.yaml \
		-c \
		-e ./properties.txt \
		-s . \
		-s SourceCode:./xilution-wordpress-docker \
		-s buildspecs:./buildspecs/infrastructure
	rm -rf ./properties.txt

test-pipeline-deploy:
	echo "XILUTION_ORGANIZATION_ID=$(XILUTION_ORGANIZATION_ID)\nK8S_CLUSTER_NAME=$(K8S_CLUSTER_NAME)\nXILUTION_PENGUIN_INSTANCE_ID=$(XILUTION_PENGUIN_INSTANCE_ID)" > ./properties.txt
	/bin/bash ./aws-codebuild-docker-images/local_builds/codebuild_build.sh \
		-i $(XILUTION_PROD_ACCOUNT_ID).dkr.ecr.us-east-1.amazonaws.com/xilution/codebuild/standard-2.0:latest \
		-p client-profile \
		-a ./output/deploy \
		-b /codebuild/output/srcDownload/secSrc/buildspecs/buildspec.yaml \
		-c \
		-e ./properties.txt \
		-s . \
		-s SourceCode:./xilution-wordpress-docker \
		-s buildspecs:./buildspecs/deploy \
		-s build_output:./output/deploy
	rm -rf ./properties.txt
