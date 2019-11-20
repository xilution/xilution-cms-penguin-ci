include ../config.mk

clean:
	@echo "nothing to do"

release-wordpress:
	helm upgrade \
		--install \
		--force \
		--values ../output-infrastructure/aurora.yaml \
		--values ../output-infrastructure/efs.yaml \
		--values ../output-build/image.yaml \
		wordpress ./wordpress

delete-wordpress:
	helm delete wordpress

init-prod:
	aws eks update-kubeconfig --region us-east-1 --name xilution-k8s --profile xilution-prod
	helm init
	kubectl create serviceaccount tiller -n kube-system
	kubectl create clusterrolebinding tiller-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
	kubectl patch deploy tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}' -n kube-system

init-test:
	aws eks update-kubeconfig --region us-east-1 --name xilution-k8s --profile xilution-test
	helm init
	kubectl create serviceaccount tiller -n kube-system
	kubectl create clusterrolebinding tiller-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
	kubectl patch deploy tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}' -n kube-system

output:
	kubectl get services/wordpress -o json | jq -r '.status.loadBalancer.ingress[0].hostname'

verify:
	helm lint wordpress
