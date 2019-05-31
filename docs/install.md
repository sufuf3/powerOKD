# Install

## Add free5gc-operator

```sh
git clone https://github.com/sufuf3/free5gc-operator.git && cd free5gc-operator
kubectl create -f deploy/crds/free5gc_v1alpha1_free5gcservice_crd.yaml
kubectl create -f deploy/namespace.yaml
kubectl create -f deploy/service_account.yaml
kubectl create -f deploy/role.yaml
kubectl create -f deploy/role_binding.yaml
kubectl create -f deploy/operator.yaml
```

## Install operator-lifecycle-manager

```sh
git clone https://github.com/operator-framework/operator-lifecycle-manager
cd operator-lifecycle-manager && git checkout 3ca040cc09ca0be39a03e65eac9ef8f5de796139 && cd -
kubectl create -f operator-lifecycle-manager/deploy/okd/manifests/0.7.2/0000_30_00-namespace.yaml
kubectl get namespaces openshift-operator-lifecycle-manager
kubectl create -f operator-lifecycle-manager/deploy/okd/manifests/0.7.2/0000_30_01-olm-operator.serviceaccount.yaml
kubectl -n openshift-operator-lifecycle-manager get serviceaccount olm-operator-serviceaccount
kubectl get clusterrole system:controller:operator-lifecycle-manager
kubectl get clusterrolebinding olm-operator-binding-openshift-operator-lifecycle-manager
for num in {02..05}; do kubectl create -f operator-lifecycle-manager/deploy/okd/manifests/0.7.2/0000_30_$num*; done
kubectl get crds
for num in {06,09}; do kubectl create -f operator-lifecycle-manager/deploy/okd/manifests/0.7.2/0000_30_$num*; done
kubectl -n openshift-operator-lifecycle-manager get catalogsource rh-operators
kubectl -n openshift-operator-lifecycle-manager get configmap rh-operators
for num in {10..13}; do kubectl create -f operator-lifecycle-manager/deploy/okd/manifests/0.7.2/0000_30_$num*; done
kubectl -n openshift-operator-lifecycle-manager get deployments
kubectl create clusterrolebinding add-on-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:default
```

## Run Web UI

```
sed -i 's|latest|v3.11.0|g' ./operator-lifecycle-manager/scripts/run_console_local.sh
./operator-lifecycle-manager/scripts/run_console_local.sh
```

> Now, you can see Free5gcService under  http://hostname:9000/k8s/cluster/customresourcedefinitions and create your own Free5gc Services.

## Todo
1. Add ONOS operator (only call onos device or host)
2. Add ONOS Web UI
