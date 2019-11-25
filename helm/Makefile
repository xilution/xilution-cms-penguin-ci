include ../config.mk
include ./config.mk

clean:
	@echo "nothing to do"

init:
	chmod u+x ./scripts/*.sh

apply:
	../scripts/update-kubeconfig.sh $(XILUTION_AWS_REGION) $(XILUTION_AWS_PROFILE)
	../scripts/start-tiller.sh
	HELM_HOST=:44134 helm upgrade \
		--install \
		--force \
  		--namespace wordpress \
  		--set mysql.name=wordpress-$(XILUTION_PENGUIN_INSTANCE_ID) \
		--values ../input-build/image.yaml \
		wordpress-$(XILUTION_PENGUIN_INSTANCE_ID) ./wordpress
	../scripts/stop-tiller.sh
	./scripts/register-load-balancer.sh $(XILUTION_PENGUIN_INSTANCE_ID)

destroy:
	../scripts/update-kubeconfig.sh $(XILUTION_AWS_REGION) $(XILUTION_AWS_PROFILE)
	../scripts/start-tiller.sh
	HELM_HOST=:44134 helm delete wordpress-$(XILUTION_PENGUIN_INSTANCE_ID)
	../scripts/stop-tiller.sh
	./scripts/deregister-load-balancer.sh $(XILUTION_PENGUIN_INSTANCE_ID)

verify:
	helm lint wordpress
