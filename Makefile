clean:
	rm -rf .terraform properties.txt

build:
	@echo "nothing to build"

infrastructure-plan:
	terraform plan \
		-var="organization_id=$(XILUTION_ORGANIZATION_ID)" \
		-var="pipeline_id=$(PIPELINE_ID)" \
		-var="client_aws_account=$(CLIENT_AWS_ACCOUNT)"

infrastructure-destroy:
	terraform destroy \
		-var="organization_id=$(XILUTION_ORGANIZATION_ID)" \
		-var="pipeline_id=$(PIPELINE_ID)" \
		-var="client_aws_account=$(CLIENT_AWS_ACCOUNT)" \
		-var="k8s_cluster_name=nonsense" \
		-auto-approve

uninstall-wordpress:
	helm tiller run tiller -- helm delete wordpress-$(PIPELINE_ID)-$(STAGE_NAME)
	helm tiller run tiller -- helm del --purge wordpress-$(PIPELINE_ID)-$(STAGE_NAME)

init:
	terraform init \
		-backend-config="key=xilution-cms-penguin/$(PIPELINE_ID)/terraform.tfstate" \
		-backend-config="bucket=xilution-terraform-backend-state-bucket-$(CLIENT_AWS_ACCOUNT)" \
		-backend-config="dynamodb_table=xilution-terraform-backend-lock-table" \
		-var="organization_id=$(XILUTION_ORGANIZATION_ID)" \
		-var="pipeline_id=$(PIPELINE_ID)" \
		-var="client_aws_account=$(CLIENT_AWS_ACCOUNT)"

submodules-init:
	git submodule update --init

submodules-update:
	git submodule update --remote

verify:
	terraform validate

pull-docker-image:
	aws ecr get-login --no-include-email --profile=xilution-prod | /bin/bash
	docker pull $(AWS_PROD_ACCOUNT_ID).dkr.ecr.us-east-1.amazonaws.com/xilution/codebuild/docker-19:latest

test-pipeline-build:
	echo "XILUTION_ORGANIZATION_ID=$(XILUTION_ORGANIZATION_ID)\nCLIENT_AWS_ACCOUNT=$(CLIENT_AWS_ACCOUNT)" > ./properties.txt
	/bin/bash ./aws-codebuild-docker-images/local_builds/codebuild_build.sh \
		-i $(AWS_PROD_ACCOUNT_ID).dkr.ecr.us-east-1.amazonaws.com/xilution/codebuild/docker-19:latest \
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
	echo "XILUTION_ORGANIZATION_ID=$(XILUTION_ORGANIZATION_ID)\nPIPELINE_ID=$(PIPELINE_ID)\nPIPELINE_ID=$(PIPELINE_ID)\nCLIENT_AWS_ACCOUNT=$(CLIENT_AWS_ACCOUNT)" > ./properties.txt
	/bin/bash ./aws-codebuild-docker-images/local_builds/codebuild_build.sh \
		-i $(AWS_PROD_ACCOUNT_ID).dkr.ecr.us-east-1.amazonaws.com/xilution/codebuild/docker-19:latest \
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
	echo "XILUTION_ORGANIZATION_ID=$(XILUTION_ORGANIZATION_ID)\nK8S_CLUSTER_NAME=$(K8S_CLUSTER_NAME)\nPIPELINE_ID=$(PIPELINE_ID)\nCLIENT_AWS_ACCOUNT=$(CLIENT_AWS_ACCOUNT)" > ./properties.txt
	/bin/bash ./aws-codebuild-docker-images/local_builds/codebuild_build.sh \
		-i $(AWS_PROD_ACCOUNT_ID).dkr.ecr.us-east-1.amazonaws.com/xilution/codebuild/docker-19:latest \
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
