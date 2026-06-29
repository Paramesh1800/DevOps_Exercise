helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm repo add grafana https://grafana.github.io/helm-charts

helm repo update

kubectl create namespace monitoring

helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring

helm install loki grafana/loki-stack -n monitoring

helm install tempo grafana/tempo -n monitoring

helm install alloy grafana/alloy -n monitoring
