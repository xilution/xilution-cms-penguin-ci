clean:
	rm -rf .terraform properties.txt

build:
	@echo "nothing to build"

infrastructure-plan:
	terraform plan \
		-var="organization_id=$(XILUTION_ORGANIZATION_ID)" \
		-var="master_username=$(WORDPRESS_DB_USERNAME)" \
		-var="master_password=$(WORDPRESS_DB_PASSWORD)"

infrastructure-destroy:
	terraform destroy \
		-var="organization_id=$(XILUTION_ORGANIZATION_ID)" \
		-var="master_username=$(WORDPRESS_DB_USERNAME)" \
		-var="master_password=$(WORDPRESS_DB_PASSWORD)" \
		-auto-approve

uninstall-wordpress:
	helm tiller run tiller -- helm delete wordpress-$(XILUTION_PENGUIN_INSTANCE_ID)

init:
	terraform init \
		-backend-config="role_arn=arn:aws:iam::$(CLIENT_AWS_ACCOUNT):role/xilution-developer-role" \
		-backend-config="key=xilution-cms-penguin/$(XILUTION_PENGUIN_INSTANCE_ID)/terraform.tfstate" \
		-backend-config="bucket=xilution-terraform-backend-state-bucket-$(CLIENT_AWS_ACCOUNT)" \
		-backend-config="dynamodb_table=xilution-terraform-backend-lock-table"

submodules:
	git submodule add https://github.com/aws/aws-codebuild-docker-images.git aws-codebuild-docker-images
	git submodule add git@github.com:xilution/xilution-wordpress-docker.git xilution-wordpress-docker

verify:
	terraform validate

test-pipeline-build:
	echo "XILUTION_ORGANIZATION_ID=$(XILUTION_ORGANIZATION_ID)\nCLIENT_AWS_ACCOUNT=$(CLIENT_AWS_ACCOUNT)\nCLIENT_AWS_REGION=$(CLIENT_AWS_REGION)" > ./properties.txt
	/bin/bash ./aws-codebuild-docker-images/local_builds/codebuild_build.sh \
		-i xilution/codebuild/standard-2.0 \
		-a ./output/build \
		-b /codebuild/output/srcDownload/secSrc/build_specs/build.yaml \
		-c \
		-e ./properties.txt \
		-s ./xilution-wordpress-docker \
		-s build_specs:./build-specs
	rm -rf ./properties.txt

test-pipeline-infrastructure:
	echo "XILUTION_ORGANIZATION_ID=$(XILUTION_ORGANIZATION_ID)\nCLIENT_AWS_ACCOUNT=$(CLIENT_AWS_ACCOUNT)\nXILUTION_GITHUB_TOKEN=$(XILUTION_GITHUB_TOKEN)\nWORDPRESS_DB_USERNAME=$(WORDPRESS_DB_USERNAME)\nWORDPRESS_DB_PASSWORD=$(WORDPRESS_DB_PASSWORD)\nXILUTION_PENGUIN_INSTANCE_ID=$(XILUTION_PENGUIN_INSTANCE_ID)" > ./properties.txt
	/bin/bash ./aws-codebuild-docker-images/local_builds/codebuild_build.sh \
		-i xilution/codebuild/standard-2.0 \
		-a ./output/infrastructure \
		-b /codebuild/output/srcDownload/secSrc/build_specs/infrastructure.yaml \
		-c \
		-e ./properties.txt \
		-s . \
		-s build_specs:./build-specs
	rm -rf ./properties.txt

test-pipeline-deploy:
	echo "XILUTION_ORGANIZATION_ID=$(XILUTION_ORGANIZATION_ID)\nK8S_CLUSTER_NAME=$(K8S_CLUSTER_NAME)\nXILUTION_PENGUIN_INSTANCE_ID=$(XILUTION_PENGUIN_INSTANCE_ID)" > ./properties.txt
	/bin/bash ./aws-codebuild-docker-images/local_builds/codebuild_build.sh \
		-i xilution/codebuild/standard-2.0 \
		-a ./output/deploy \
		-b /codebuild/output/srcDownload/secSrc/build_specs/deploy.yaml \
		-c \
		-e ./properties.txt \
		-s . \
		-s build_specs:./build-specs \
		-s build_output:./output/build
	rm -rf ./properties.txt
