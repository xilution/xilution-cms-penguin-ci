include ../config.mk

clean:
	echo "nothing to do"

wordpress-release:
	helm upgrade \
		--install \
		--force \
		--values ../output-infrastructure/aurora.yaml \
		--values ../output-infrastructure/efs.yaml \
		--values ../output-build/image.yaml \
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
