include ./config.mk

wordpress-release:
	helm upgrade \
		--install \
		--force \
		--set wordpress.image.repository=952573012699.dkr.ecr.us-east-1.amazonaws.com/xilution/1645137c2f53427da00edaa680256215/custom-wordpress,wordpress.image.tag=1.0.0 \
		wordpress ./helm/wordpress

wordpress-delete:
	helm delete wordpress

clean:
	rm -rf .terraform *.tfstate*

clean-test:
	aws s3 rm s3://$(PRODUCT_NAME)-data-test --recursive --profile xilution-test

clean-prod:
	aws s3 rm s3://$(PRODUCT_NAME)-data-prod --recursive --profile xilution-prod

cluster-plan-prod:
	terraform plan \
		-var="organization_id=$(XILUTION_ORGANIZATION_ID)" \
		-var="profile=xilution-prod" \
		./terraform/cluster

cluster-plan-test:
	terraform plan \
		-var="organization_id=$(XILUTION_ORGANIZATION_ID)" \
		-var="profile=xilution-test" \
		./terraform/cluster

cluster-apply-prod:
	terraform apply \
		-var="organization_id=$(XILUTION_ORGANIZATION_ID)" \
		-var="profile=xilution-prod" \
		./terraform/cluster

cluster-apply-test:
	terraform apply \
		-var="organization_id=$(XILUTION_ORGANIZATION_ID)" \
		-var="profile=xilution-test" \
		./terraform/cluster

cluster-destroy-prod:
	terraform destroy \
		-var="organization_id=$(XILUTION_ORGANIZATION_ID)" \
		-var="profile=xilution-prod" \
		./terraform/cluster

cluster-destroy-test:
	terraform destroy \
		-var="organization_id=$(XILUTION_ORGANIZATION_ID)" \
		-var="profile=xilution-test" \
		./terraform/cluster

cluster-init-prod:
	aws eks update-kubeconfig \
		--region us-east-1 \
		--name xilution-k8s \
		--profile xilution-prod
	kubectl apply -f config-map-aws-auth_xilution-k8s.yaml
	helm init
	kubectl create serviceaccount tiller -n kube-system
	kubectl create clusterrolebinding tiller-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
	kubectl patch deploy tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}' -n kube-system

cluster-init-test:
	aws eks update-kubeconfig \
		--region us-east-1 \
		--name xilution-k8s \
		--profile xilution-test
	kubectl apply -f config-map-aws-auth_xilution-k8s.yaml
	helm init
	kubectl create serviceaccount tiller -n kube-system
	kubectl create clusterrolebinding tiller-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
	kubectl patch deploy tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}' -n kube-system

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
	helm lint helm/wordpress
	terraform validate ./terraform
