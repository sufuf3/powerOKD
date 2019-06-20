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

#### 2. Setup Admin Web UI & api

```sh
export endpoint=$(kubectl config view -o json | jq '{myctx: .["current-context"], ctxs: .contexts[], clusters: .clusters[]}' | jq 'select(.myctx == .ctxs.name)' | jq 'select(.ctxs.context.cluster ==  .clusters.name)' | jq '.clusters.cluster.server' -r)
sed -i 's|K8S_ENDPOINT|'"$endpoint"'|g' operator-lifecycle-manager/origin-console-deployment.yaml
export secret_token=$(kubectl get secret "$(kubectl get serviceaccount default --namespace=kube-system -o jsonpath='{.secrets[0].name}')" --namespace=kube-system -o template --template='{{.data.token}}' | base64 --decode)
sed -i 's|K8S_SECRET_TOKEN|'"$secret_token"'|g' operator-lifecycle-manager/origin-console-deployment.yaml
kubectl create -f operator-lifecycle-manager/origin-console-deployment.yaml
```


> Now, you can see Free5gcService under  http://hostname:31900/k8s/cluster/customresourcedefinitions and create your own Free5gc Services.

#### 3. API Usage

URL 是 `http://Node-ip:Node-Port/api/kubernetes/oapi/v1`, eg `http://Node-IP:31900/api/kubernetes/oapi/v1`    
直接使用 Web UI 也可以直接 access `http://Node-ip:Node-Port/api/kubernetes/oapi/v1`   

若用 K8s 內網  
```
$ kubectl get svc -n kube-system
NAME                   TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                         AGE
kube-dns               ClusterIP   10.96.0.10      <none>        53/UDP,53/TCP                   40h
kubernetes-dashboard   NodePort    10.102.56.25    <none>        443:32641/TCP                   40h
origin-dashboard       NodePort    10.105.37.175   <none>        9000:31900/TCP,8443:31844/TCP   21s
tiller-deploy          ClusterIP   10.99.218.206   <none>        44134/TCP                       40h
```

URL 是 `http://10.105.37.175:9000/api/kubernetes/oapi/v1`  
其他 API 的使用，請參閱 https://docs.okd.io/latest/rest_api/index.html  
請切記 文件中的 `https://openshift.redhat.com:8443` 都要換成 `http://10.105.37.175:9000/api/kubernetes` 即可  
  
使用 Service Account Tokens 的方法  

```sh
$ export secret_token=$(kubectl get secret "$(kubectl get serviceaccount default --namespace=kube-system -o jsonpath='{.secrets[0].name}')" --namespace=kube-system -o template --template='{{.data.token}}' | base64 --decode)
$ curl -X GET -H "Authorization: Bearer $secret_token" http://10.105.37.175:9000/api/kubernetes/oapi/v1 --insecure
{
  "paths": [
    "/apis",
    "/apis/",
    "/apis/apiextensions.k8s.io",
    "/apis/apiextensions.k8s.io/v1beta1",
    "/healthz",
    "/healthz/etcd",
    "/healthz/log",
    "/healthz/ping",
    "/healthz/poststarthook/generic-apiserver-start-informers",
    "/healthz/poststarthook/start-apiextensions-controllers",
    "/healthz/poststarthook/start-apiextensions-informers",
    "/metrics",
    "/openapi/v2",
    "/swagger-2.0.0.json",
    "/swagger-2.0.0.pb-v1",
    "/swagger-2.0.0.pb-v1.gz",
    "/swagger.json",
    "/swaggerapi",
    "/version"
  ]
}
```
