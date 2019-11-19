include ../config.mk

wordpress-release:
	helm upgrade \
		--install \
		--force \
		--values ../output/aurora.yaml \
		--values ../output/efs.yaml \
		--values ../output/image.yaml \
		wordpress ./wordpress

wordpress-delete:
	helm delete wordpress

init-prod:
	helm init
	kubectl create serviceaccount tiller -n kube-system
	kubectl create clusterrolebinding tiller-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
	kubectl patch deploy tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}' -n kube-system

init-test:
	helm init
	kubectl create serviceaccount tiller -n kube-system
	kubectl create clusterrolebinding tiller-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
	kubectl patch deploy tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}' -n kube-system

verify:
	helm lint wordpress
