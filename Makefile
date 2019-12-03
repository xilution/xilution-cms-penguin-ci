clean:
	rm -rf .terraform properties.txt

infrastructure-plan:
	terraform plan \
		-var="k8s_cluster_name=$(K8S_CLUSTER_NAME)" \
		-var="organization_id=$(XILUTION_ORGANIZATION_ID)" \
		-var="profile=$(XILUTION_AWS_PROFILE)"

infrastructure-destroy:
	terraform destroy \
		-var="k8s_cluster_name=$(K8S_CLUSTER_NAME)" \
		-var="organization_id=$(XILUTION_ORGANIZATION_ID)" \
		-var="profile=$(XILUTION_AWS_PROFILE)" \
		-auto-approve

uninstall-wordpress:
	helm tiller run tiller -- helm delete wordpress-$(XILUTION_PENGUIN_INSTANCE_ID)

init:
	terraform init \
		-backend-config="key=$(XILUTION_ORGANIZATION_ID)/terraform.tfstate" \
		-backend-config="bucket=xilution-cms-penguin-infrastructure-terraform-backend-$(XILUTION_ENVIRONMENT)" \
		-backend-config="dynamodb_table=xilution-cms-penguin-infrastructure-terraform-backend-lock" \
		-backend-config="region=$(XILUTION_AWS_REGION)" \
		-backend-config="profile=$(XILUTION_AWS_PROFILE)"

submodules:
	git submodule add https://github.com/aws/aws-codebuild-docker-images.git aws-codebuild-docker-images
	git submodule add git@github.com:xilution/xilution-wordpress-docker.git xilution-wordpress-docker

verify:
	terraform validate

test-pipeline-build:
	/bin/bash ./scripts/build-properties.sh
	/bin/bash ./aws-codebuild-docker-images/local_builds/codebuild_build.sh \
		-i xilution/codebuild/standard-2.0 \
		-a ./output/build \
		-b /codebuild/output/srcDownload/secSrc/build_specs/build.yaml \
		-c \
		-e properties.txt \
		-s ./xilution-wordpress-docker \
		-s build_specs:./build-specs

test-pipeline-infrastructure:
	/bin/bash ./scripts/build-properties.sh
	/bin/bash ./aws-codebuild-docker-images/local_builds/codebuild_build.sh \
		-i xilution/codebuild/standard-2.0 \
		-a ./output/infrastructure \
		-b /codebuild/output/srcDownload/secSrc/build_specs/infrastructure.yaml \
		-c \
		-e properties.txt \
		-s . \
		-s build_specs:./build-specs

test-pipeline-deploy:
	/bin/bash ./scripts/build-properties.sh
	/bin/bash ./aws-codebuild-docker-images/local_builds/codebuild_build.sh \
		-i xilution/codebuild/standard-2.0 \
		-a ./output/deploy \
		-b /codebuild/output/srcDownload/secSrc/build_specs/deploy.yaml \
		-c \
		-e properties.txt \
		-s . \
		-s build_specs:./build-specs \
		-s build_output:./output/build
