include ../config.mk
include ./config.mk

clean:
	@echo "nothing to do"

init:
	@echo "nothing to do"

release-wordpress:
	helm upgrade \
		--install \
		--force \
		--values ../output-infrastructure/aurora.yaml \
		--values ../output-infrastructure/efs.yaml \
		--values ../output-build/image.yaml \
		wordpress-$(XILUTION_PENGUIN_INSTANCE_ID) ./wordpress

delete-wordpress:
	helm delete wordpress-$(XILUTION_PENGUIN_INSTANCE_ID)

set-up:
	aws eks update-kubeconfig --region $(XILUTION_AWS_REGION) --name xilution-k8s --profile $(XILUTION_AWS_PROFILE)
	kubectl create namespace $(TILLER_NAMESPACE)
	tiller -listen=$(TILLER_HOST) -storage=secret -logtostderr & ; echo $! > tiller.pid
	sleep 5
	helm init --client-only

tear-down:
	kill `cat tiller.pid`

output:
	./scripts/register-load-balancer.sh $(XILUTION_PENGUIN_INSTANCE_ID)

verify:
	helm lint wordpress
