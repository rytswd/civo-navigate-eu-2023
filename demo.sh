#!/usr/bin/env bash

# shellcheck disable=SC2016

# shellcheck disable=SC2034
demo_helper_type_speed=5000

# shellcheck source=./demo-helper.sh
. "$(dirname "$0")/demo-helper.sh"

comment "Step 1."
execute '{
   mkdir /tmp/civo-nav-mco-demo
   cd /tmp/civo-nav-mco-demo
   curl -sSL https://codeload.github.com/rytswd/civo-navigate-eu-2023/tar.gz/main \
        -o civo-navigate-eu-2023.tar.gz
}'

comment "Step 2.1."
execute '{
   curl -sSL https://codeload.github.com/istio/istio/tar.gz/1.18.2 |
       tar -xz --strip=2 istio-1.18.2/tools/certs;
}'
comment "Step 2.2."
execute '{
   pushd certs > /dev/null
}'
comment "Step 2.3."
execute '{
   make -f ./Makefile.selfsigned.mk root-ca &> /dev/null
}'
comment "Step 2.4."
execute '{
   make -f ./Makefile.selfsigned.mk cluster-1-cacerts &> /dev/null
   make -f ./Makefile.selfsigned.mk cluster-2-cacerts &> /dev/null
   make -f ./Makefile.selfsigned.mk cluster-3-cacerts &> /dev/null
}'
comment "Step 2.5."
execute '{
   popd > /dev/null
}'
comment "Step 2.6."
execute '{
   kubectl create namespace --context cluster-1 istio-system
   kubectl create namespace --context cluster-2 istio-system
   kubectl create namespace --context cluster-3 istio-system
}'
comment "Step 2.7."
execute '{
   kubectl create secret --context cluster-1 \
       generic cacerts -n istio-system \
       --from-file=./certs/cluster-1/ca-cert.pem \
       --from-file=./certs/cluster-1/ca-key.pem \
       --from-file=./certs/cluster-1/root-cert.pem \
       --from-file=./certs/cluster-1/cert-chain.pem;
   kubectl create secret --context cluster-2 \
       generic cacerts -n istio-system \
       --from-file=./certs/cluster-2/ca-cert.pem \
       --from-file=./certs/cluster-2/ca-key.pem \
       --from-file=./certs/cluster-2/root-cert.pem \
       --from-file=./certs/cluster-2/cert-chain.pem;
   kubectl create secret --context cluster-3 \
       generic cacerts -n istio-system \
       --from-file=./certs/cluster-3/ca-cert.pem \
       --from-file=./certs/cluster-3/ca-key.pem \
       --from-file=./certs/cluster-3/root-cert.pem \
       --from-file=./certs/cluster-3/cert-chain.pem
}'

comment "Step 3.1 ~ Step 3.3."
execute '{
   tar -xz -f civo-navigate-eu-2023.tar.gz \
       --strip=2 civo-navigate-eu-2023-main/manifests/istio/installation
   kubectl label namespace \
       --context=cluster-1 \
       istio-system topology.istio.io/network=cluster-1-network
   kubectl label namespace \
       --context=cluster-2 \
       istio-system topology.istio.io/network=cluster-2-network
   kubectl label namespace \
       --context=cluster-3 \
       istio-system topology.istio.io/network=cluster-3-network
   kubectl apply --context cluster-1 \
       -f ./istio/installation/istiod-manifests-cluster-1.yaml
   kubectl apply --context cluster-2 \
       -f ./istio/installation/istiod-manifests-cluster-2.yaml
   kubectl apply --context cluster-3 \
       -f ./istio/installation/istiod-manifests-cluster-3.yaml
}'
# Because of the CRD dependency, the below needs to rerun.
comment "Step 3.3. Rerun"
execute '{
   kubectl apply --context cluster-1 \
       -f ./istio/installation/istiod-manifests-cluster-1.yaml
   kubectl apply --context cluster-2 \
       -f ./istio/installation/istiod-manifests-cluster-2.yaml
   kubectl apply --context cluster-3 \
       -f ./istio/installation/istiod-manifests-cluster-3.yaml
}'

comment "Step 4."
execute '{
   echo "...cluster-1..."
   kubectl apply --context cluster-1 \
       -f ./istio/installation/istio-gateway-manifests-cluster-1.yaml
   echo "...cluster-2..."
   kubectl apply --context cluster-2 \
       -f ./istio/installation/istio-gateway-manifests-cluster-2.yaml
   echo "...cluster-3..."
   kubectl apply --context cluster-3 \
       -f ./istio/installation/istio-gateway-manifests-cluster-3.yaml
}'

comment "Step 5."
execute '{
   tar -xz -f civo-navigate-eu-2023.tar.gz \
       --strip=2 civo-navigate-eu-2023-main/manifests/istio/usage/cross-network-gateway.yaml
   kubectl apply --context cluster-1 \
       -f ./istio/usage/cross-network-gateway.yaml
   kubectl apply --context cluster-2 \
       -f ./istio/usage/cross-network-gateway.yaml
   kubectl apply --context cluster-3 \
       -f ./istio/usage/cross-network-gateway.yaml
}'

comment "Step 6."
execute '{
   kubectl create namespace --context cluster-1 monitoring
   kubectl create namespace --context cluster-2 monitoring
   kubectl create namespace --context cluster-3 monitoring
   kubectl label --context cluster-1 \
       namespace monitoring istio-injection=enabled
   kubectl label --context cluster-2 \
       namespace monitoring istio-injection=enabled
   kubectl label --context cluster-3 \
       namespace monitoring istio-injection=enabled
   tar -xz -f civo-navigate-eu-2023.tar.gz \
         --strip=2 civo-navigate-eu-2023-main/manifests/prometheus
   kustomize build prometheus/operator-installation |
       kubectl apply --context cluster-1 --server-side -f -
   kustomize build prometheus/operator-installation |
       kubectl apply --context cluster-2 --server-side -f -
   kustomize build prometheus/operator-installation |
       kubectl apply --context cluster-3 --server-side -f -
   kustomize build prometheus/istio-collector |
       kubectl apply --context cluster-1 -f -
   kustomize build prometheus/istio-collector |
       kubectl apply --context cluster-2 -f -
   kustomize build prometheus/istio-collector |
       kubectl apply --context cluster-3 -f -
   kustomize build prometheus/istio-federation-cluster-1 |
       kubectl apply --context cluster-1 -f -
   kustomize build prometheus/istio-federation-cluster-2 |
       kubectl apply --context cluster-2 -f -
   kustomize build prometheus/istio-federation-cluster-3 |
       kubectl apply --context cluster-3 -f -
}'

comment "Step 7."
execute '{
   helm install --repo https://charts.bitnami.com/bitnami \
       --kube-context cluster-3 \
       --set receive.enabled=true \
       thanos thanos -n monitoring
}'

comment "Step 8."
execute '{
   helm install --repo https://grafana.github.io/helm-charts \
       --kube-context cluster-3 \
       --set sidecar.dashboards.enabled=true \
       --set sidecar.datasources.enabled=true \
       grafana grafana -n monitoring
   tar -xz -f civo-navigate-eu-2023.tar.gz \
       --strip=2 civo-navigate-eu-2023-main/manifests/grafana
   
   ls -aF /tmp/civo-nav-mco-demo/grafana
   kustomize build grafana |
       kubectl apply --context cluster-3 -f -
}'

comment "Step 9."
execute '{
   kubectl get secret \
       --context cluster-3 \
       --namespace monitoring \
       grafana \
       -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
   kubectl port-forward \
       --context cluster-3 \
       --namespace monitoring \
       svc/grafana 3000:80 &> /dev/null &
}'
