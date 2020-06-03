clean:
	rm -rf .terraform properties.txt

build:
	@echo "nothing to build"

infrastructure-plan:
	terraform plan \
		-var="organization_id=$(XILUTION_ORGANIZATION_ID)" \
		-var="penguin_pipeline_id=$(PENGUIN_PIPELINE_ID)" \
		-var="giraffe_pipeline_id=$(GIRAFFE_PIPELINE_ID)" \
		-var="client_aws_account=$(CLIENT_AWS_ACCOUNT)" \
		terraform/infrastructure

infrastructure-destroy:
	terraform destroy \
		-var="organization_id=$(XILUTION_ORGANIZATION_ID)" \
		-var="penguin_pipeline_id=$(PENGUIN_PIPELINE_ID)" \
		-var="giraffe_pipeline_id=$(GIRAFFE_PIPELINE_ID)" \
		-var="client_aws_account=$(CLIENT_AWS_ACCOUNT)" \
		-var="k8s_cluster_name=nonsense" \
		-var="master_username=nonsense" \
		-var="master_password=nonsense" \
		-var="docker_username=nonsense" \
		-var="docker_password=nonsense" \
		-auto-approve \
		terraform/infrastructure

infrastructure-init:
	terraform init \
		-backend-config="key=xilution-cms-penguin/$(PENGUIN_PIPELINE_ID)/terraform.tfstate" \
		-backend-config="bucket=xilution-terraform-backend-state-bucket-$(CLIENT_AWS_ACCOUNT)" \
		-backend-config="dynamodb_table=xilution-terraform-backend-lock-table" \
		-var="organization_id=$(XILUTION_ORGANIZATION_ID)" \
		-var="penguin_pipeline_id=$(PENGUIN_PIPELINE_ID)" \
		-var="giraffe_pipeline_id=$(GIRAFFE_PIPELINE_ID)" \
		-var="client_aws_account=$(CLIENT_AWS_ACCOUNT)" \
		terraform/infrastructure

uninstall-wordpress:
	helm tiller run tiller -- helm delete wordpress-$(PENGUIN_PIPELINE_ID)-$(STAGE_NAME)
	helm tiller run tiller -- helm del --purge wordpress-$(PENGUIN_PIPELINE_ID)-$(STAGE_NAME)

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

test-pipeline-infrastructure-up:
	echo "XILUTION_ORGANIZATION_ID=$(XILUTION_ORGANIZATION_ID)\nPENGUIN_PIPELINE_ID=$(PENGUIN_PIPELINE_ID)\nGIRAFFE_PIPELINE_ID=$(GIRAFFE_PIPELINE_ID)\nCLIENT_AWS_ACCOUNT=$(CLIENT_AWS_ACCOUNT)" > ./properties.txt
	/bin/bash ./aws-codebuild-docker-images/local_builds/codebuild_build.sh \
		-i $(AWS_PROD_ACCOUNT_ID).dkr.ecr.us-east-1.amazonaws.com/xilution/codebuild/docker-19:latest \
		-p client-profile \
		-a ./output/infrastructure \
		-b /codebuild/output/srcDownload/secSrc/buildspecs/buildspec-up.yaml \
		-c \
		-e ./properties.txt \
		-s . \
		-s SourceCode:./xilution-wordpress-docker \
		-s buildspecs:./buildspecs/infrastructure
	rm -rf ./properties.txt

test-pipeline-infrastructure-down:
	echo "XILUTION_ORGANIZATION_ID=$(XILUTION_ORGANIZATION_ID)\nPENGUIN_PIPELINE_ID=$(PENGUIN_PIPELINE_ID)\nGIRAFFE_PIPELINE_ID=$(GIRAFFE_PIPELINE_ID)\nCLIENT_AWS_ACCOUNT=$(CLIENT_AWS_ACCOUNT)" > ./properties.txt
	/bin/bash ./aws-codebuild-docker-images/local_builds/codebuild_build.sh \
		-i $(AWS_PROD_ACCOUNT_ID).dkr.ecr.us-east-1.amazonaws.com/xilution/codebuild/docker-19:latest \
		-p client-profile \
		-a ./output/infrastructure \
		-b /codebuild/output/srcDownload/secSrc/buildspecs/buildspec-down.yaml \
		-c \
		-e ./properties.txt \
		-s . \
		-s SourceCode:./xilution-wordpress-docker \
		-s buildspecs:./buildspecs/infrastructure
	rm -rf ./properties.txt

test-pipeline-deploy-up:
	echo "XILUTION_ORGANIZATION_ID=$(XILUTION_ORGANIZATION_ID)\nK8S_CLUSTER_NAME=$(K8S_CLUSTER_NAME)\nPENGUIN_PIPELINE_ID=$(PENGUIN_PIPELINE_ID)\nCLIENT_AWS_ACCOUNT=$(CLIENT_AWS_ACCOUNT)" > ./properties.txt
	/bin/bash ./aws-codebuild-docker-images/local_builds/codebuild_build.sh \
		-i $(AWS_PROD_ACCOUNT_ID).dkr.ecr.us-east-1.amazonaws.com/xilution/codebuild/docker-19:latest \
		-p client-profile \
		-a ./output/deploy \
		-b /codebuild/output/srcDownload/secSrc/buildspecs/buildspec-up.yaml \
		-c \
		-e ./properties.txt \
		-s . \
		-s SourceCode:./xilution-wordpress-docker \
		-s buildspecs:./buildspecs/deploy \
		-s build_output:./output/deploy
	rm -rf ./properties.txt

test-pipeline-deploy-down:
	echo "XILUTION_ORGANIZATION_ID=$(XILUTION_ORGANIZATION_ID)\nK8S_CLUSTER_NAME=$(K8S_CLUSTER_NAME)\nPENGUIN_PIPELINE_ID=$(PENGUIN_PIPELINE_ID)\nCLIENT_AWS_ACCOUNT=$(CLIENT_AWS_ACCOUNT)" > ./properties.txt
	/bin/bash ./aws-codebuild-docker-images/local_builds/codebuild_build.sh \
		-i $(AWS_PROD_ACCOUNT_ID).dkr.ecr.us-east-1.amazonaws.com/xilution/codebuild/docker-19:latest \
		-p client-profile \
		-a ./output/deploy \
		-b /codebuild/output/srcDownload/secSrc/buildspecs/buildspec-down.yaml \
		-c \
		-e ./properties.txt \
		-s . \
		-s SourceCode:./xilution-wordpress-docker \
		-s buildspecs:./buildspecs/deploy \
		-s build_output:./output/deploy
	rm -rf ./properties.txt
