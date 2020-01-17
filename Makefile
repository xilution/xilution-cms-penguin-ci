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
	aws sts assume-role --role-arn arn:aws:iam::$(CLIENT_AWS_ACCOUNT):role/xilution-developer-role --role-session-name xilution-beta > aws-creds.json
	export AWS_ACCESS_KEY_ID=`cat aws-creds.json | jq -r '.Credentials.AccessKeyId'`
	export AWS_SECRET_ACCESS_KEY=`cat aws-creds.json | jq -r '.Credentials.SecretAccessKey'`
	export AWS_SESSION_TOKEN=`cat aws-creds.json | jq -r '.Credentials.SessionToken'`
	aws eks update-kubeconfig --name $(K8S_CLUSTER_NAME)
	helm tiller run tiller -- helm delete wordpress-$(XILUTION_PENGUIN_INSTANCE_ID)

init:
	terraform init \
		-backend-config="role_arn=arn:aws:iam::$(CLIENT_AWS_ACCOUNT):role/xilution-developer-role" \
		-backend-config="key=xilution-cms-penguin/$(XILUTION_PENGUIN_INSTANCE_ID)/terraform.tfstate" \
		-backend-config="bucket=xilution-terraform-backend-state-bucket-$(CLIENT_AWS_ACCOUNT)" \
		-backend-config="dynamodb_table=xilution-terraform-backend-lock-table" \
		-var="client_aws_account=$(CLIENT_AWS_ACCOUNT)"

submodules-init:
	git submodule update --init

verify:
	terraform validate

pull-docker-image:
	aws ecr get-login --no-include-email | /bin/bash
	docker pull $(AWS_ACCOUNT).dkr.ecr.$(AWS_REGION).amazonaws.com/xilution/codebuild/standard-2.0:latest

test-pipeline-build:
	echo "XILUTION_ORGANIZATION_ID=$(XILUTION_ORGANIZATION_ID)\nCLIENT_AWS_ACCOUNT=$(CLIENT_AWS_ACCOUNT)\nCLIENT_AWS_REGION=$(CLIENT_AWS_REGION)" > ./properties.txt
	/bin/bash ./aws-codebuild-docker-images/local_builds/codebuild_build.sh \
		-i $(AWS_ACCOUNT).dkr.ecr.$(AWS_REGION).amazonaws.com/xilution/codebuild/standard-2.0:latest \
		-a ./output/build \
		-b /codebuild/output/srcDownload/secSrc/buildspecs/buildspec.yaml \
		-c \
		-e ./properties.txt \
		-s ./xilution-wordpress-docker \
		-s buildspecs:./buildspecs/build
	rm -rf ./properties.txt

test-pipeline-infrastructure:
	echo "XILUTION_ORGANIZATION_ID=$(XILUTION_ORGANIZATION_ID)\nCLIENT_AWS_ACCOUNT=$(CLIENT_AWS_ACCOUNT)\nXILUTION_PENGUIN_INSTANCE_ID=$(XILUTION_PENGUIN_INSTANCE_ID)" > ./properties.txt
	/bin/bash ./aws-codebuild-docker-images/local_builds/codebuild_build.sh \
		-i $(AWS_ACCOUNT).dkr.ecr.$(AWS_REGION).amazonaws.com/xilution/codebuild/standard-2.0:latest \
		-a ./output/infrastructure \
		-b /codebuild/output/srcDownload/secSrc/buildspecs/buildspec.yaml \
		-c \
		-e ./properties.txt \
		-s . \
		-s buildspecs:./buildspecs/infrastructure
	rm -rf ./properties.txt

test-pipeline-deploy:
	echo "XILUTION_ORGANIZATION_ID=$(XILUTION_ORGANIZATION_ID)\nK8S_CLUSTER_NAME=$(K8S_CLUSTER_NAME)\nXILUTION_PENGUIN_INSTANCE_ID=$(XILUTION_PENGUIN_INSTANCE_ID)" > ./properties.txt
	/bin/bash ./aws-codebuild-docker-images/local_builds/codebuild_build.sh \
		-i $(AWS_ACCOUNT).dkr.ecr.$(AWS_REGION).amazonaws.com/xilution/codebuild/standard-2.0:latest \
		-a ./output/deploy \
		-b /codebuild/output/srcDownload/secSrc/buildspecs/buildspec.yaml \
		-c \
		-e ./properties.txt \
		-s . \
		-s buildspecs:./buildspecs/deploy \
		-s build_output:./output/deploy
	rm -rf ./properties.txt
