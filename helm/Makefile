include ../config.mk
include ./config.mk

clean:
	@echo "nothing to do"

init:
	chmod u+x ./scripts/*.sh

release-wordpress:
	../scripts/update-kubeconfig.sh $(XILUTION_AWS_REGION) $(XILUTION_AWS_PROFILE)
	../scripts/start-tiller.sh
	helm upgrade \
		--install \
		--force \
  		--namespace wordpress \
  		--set mysql.name=wordpress-$(XILUTION_PENGUIN_INSTANCE_ID) \
		--values ../input-build/image.yaml \
		wordpress-$(XILUTION_PENGUIN_INSTANCE_ID) ./wordpress
	./scripts/register-load-balancer.sh $(XILUTION_PENGUIN_INSTANCE_ID)
	../scripts/stop-tiller.sh

delete-wordpress:
	../scripts/update-kubeconfig.sh $(XILUTION_AWS_REGION) $(XILUTION_AWS_PROFILE)
	../scripts/start-tiller.sh
	helm delete wordpress-$(XILUTION_PENGUIN_INSTANCE_ID)
	./scripts/register-load-balancer.sh $(XILUTION_PENGUIN_INSTANCE_ID)
	../scripts/stop-tiller.sh

verify:
	helm lint wordpress
