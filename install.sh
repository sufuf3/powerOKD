# Deploy free5gc-operator
cd ~/ && git clone https://github.com/sufuf3/free5gc-operator.git
kubectl create -f ~/free5gc-operator/deploy/crds/free5gc_v1alpha1_free5gcservice_crd.yaml
kubectl create -f ~/free5gc-operator/deploy/namespace.yaml
kubectl create -f ~/free5gc-operator/deploy/service_account.yaml
kubectl create -f ~/free5gc-operator/deploy/role.yaml
kubectl create -f ~/free5gc-operator/deploy/role_binding.yaml
kubectl create -f ~/free5gc-operator/deploy/operator.yaml
# Deploy onosjob-operator
cd ~/ && git clone https://github.com/sufuf3/onosjob-operator.git
kubectl create -f ~/onosjob-operator/deploy/crds/onosjob_v1alpha1_onosjob_crd.yaml
kubectl create -f ~/onosjob-operator/deploy/service_account.yaml
kubectl create -f ~/onosjob-operator/deploy/role.yaml
kubectl create -f ~/onosjob-operator/deploy/role_binding.yaml
kubectl create -f ~/onosjob-operator/deploy/operator.yaml
# Install ONOS
helm repo add cord https://charts.opencord.org
helm repo update
helm install -n onos cord/onos
sudo apt install -y mininet
# Setup operator-lifecycle-manager
cd ~/ && git clone https://github.com/sufuf3/operator-lifecycle-manager.git
kubectl create -f ~/operator-lifecycle-manager/deploy/okd/manifests/0.7.2/0000_30_00-namespace.yaml
kubectl get namespaces openshift-operator-lifecycle-manager
kubectl create -f ~/operator-lifecycle-manager/deploy/okd/manifests/0.7.2/0000_30_01-olm-operator.serviceaccount.yaml
kubectl -n openshift-operator-lifecycle-manager get serviceaccount olm-operator-serviceaccount
kubectl get clusterrole system:controller:operator-lifecycle-manager
kubectl get clusterrolebinding olm-operator-binding-openshift-operator-lifecycle-manager
#for num in {02..05}; do kubectl create -f ~/operator-lifecycle-manager/deploy/okd/manifests/0.7.2/0000_30_$num*; done
kubectl create -f ~/operator-lifecycle-manager/deploy/okd/manifests/0.7.2/0000_30_
kubectl create -f ~/operator-lifecycle-manager/deploy/okd/manifests/0.7.2/0000_30_02-clusterserviceversion.crd.yaml
kubectl create -f ~/operator-lifecycle-manager/deploy/okd/manifests/0.7.2/0000_30_03-installplan.crd.yaml
kubectl create -f ~/operator-lifecycle-manager/deploy/okd/manifests/0.7.2/0000_30_04-subscription.crd.yaml
kubectl create -f ~/operator-lifecycle-manager/deploy/okd/manifests/0.7.2/0000_30_05-catalogsource.crd.yaml
kubectl get crds
#for num in {06,09}; do kubectl create -f ~/operator-lifecycle-manager/deploy/okd/manifests/0.7.2/0000_30_$num*; done
kubectl create -f ~/operator-lifecycle-manager/deploy/okd/manifests/0.7.2/0000_30_06-rh-operators.configmap.yaml
kubectl create -f ~/operator-lifecycle-manager/deploy/okd/manifests/0.7.2/0000_30_09-rh-operators.catalogsource.yaml
kubectl -n openshift-operator-lifecycle-manager get catalogsource rh-operators
kubectl -n openshift-operator-lifecycle-manager get configmap rh-operators
#for num in {10..13}; do kubectl create -f ~/operator-lifecycle-manager/deploy/okd/manifests/0.7.2/0000_30_$num*; done
kubectl create -f ~/operator-lifecycle-manager/deploy/okd/manifests/0.7.2/0000_30_10-olm-operator.deployment.yaml
kubectl create -f ~/operator-lifecycle-manager/deploy/okd/manifests/0.7.2/0000_30_11-catalog-operator.deployment.yaml
kubectl create -f ~/operator-lifecycle-manager/deploy/okd/manifests/0.7.2/0000_30_12-aggregated.clusterrole.yaml
kubectl create -f ~/operator-lifecycle-manager/deploy/okd/manifests/0.7.2/0000_30_13-packageserver.yaml
kubectl -n openshift-operator-lifecycle-manager get deployments
kubectl create clusterrolebinding add-on-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:default
#export endpoint=$(kubectl config view -o json | jq '{myctx: .["current-context"], ctxs: .contexts[], clusters: .clusters[]}' | jq 'select(.myctx == .ctxs.name)' | jq 'select(.ctxs.context.cluster ==  .clusters.name)' | jq '.clusters.cluster.server' -r)
export endpoint=$(sudo cat /etc/kubernetes/admin.conf | grep server | cut -f 2- -d ":" | tr -d " ")
sed -i 's|K8S_ENDPOINT|'"$endpoint"'|g' ~/operator-lifecycle-manager/origin-console-deployment.yaml
export secret_token=$(kubectl get secret "$(kubectl get serviceaccount default --namespace=kube-system -o jsonpath='{.secrets[0].name}')" --namespace=kube-system -o template --template='{{.data.token}}' | base64 --decode)
sed -i 's|K8S_SECRET_TOKEN|'"$secret_token"'|g' ~/operator-lifecycle-manager/origin-console-deployment.yaml
kubectl create -f ~/operator-lifecycle-manager/origin-console-deployment.yaml
