# Exercise 25 - Observability Platform Deployment

## Objective

Deploy a complete Kubernetes observability platform using:

- Prometheus
- Grafana
- Loki
- Tempo
- Alloy

The platform collects:

- Metrics
- Logs
- Traces

and visualizes them in Grafana dashboards.

---

## Architecture

```
Application
      │
      │
      ▼
Alloy
 ├────────► Loki (Logs)
 ├────────► Tempo (Traces)
 └────────► Prometheus (Metrics)
                    │
                    ▼
               Grafana
```

---

## Prerequisites

- AWS CLI
- kubectl
- Helm
- Existing EKS Cluster
- Monitoring Namespace

---

## Installation

### Add repositories

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```

---

### Install Prometheus + Grafana

```bash
helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring
```

---

### Install Loki

```bash
helm install loki grafana/loki-stack -n monitoring
```

---

### Install Tempo

```bash
helm install tempo grafana/tempo -n monitoring
```

---

### Install Alloy

```bash
helm install alloy grafana/alloy -n monitoring
```

---

## Verify Installation

```bash
kubectl get pods -n monitoring
```

Expected Components

- Prometheus
- Grafana
- Alertmanager
- Node Exporter
- kube-state-metrics
- Loki
- Promtail
- Tempo
- Alloy

---

## Grafana

Port Forward

```bash
kubectl port-forward svc/monitoring-grafana 3000:80 -n monitoring
```

Login

Username

`admin`

Password

```bash
kubectl get secret monitoring-grafana -n monitoring -o jsonpath="{.data.admin-password}"
```
Note: Use a base64 decoder on the output if it's encoded, or standard jsonpath as above.

---

## Deploy Sample Application

```bash
kubectl apply -f manifests/nginx.yaml
```

Port Forward Sample App:
```bash
kubectl port-forward svc/nginx 8080:80
```

Generate traffic using browser or curl.

---

## Dashboards

CPU Usage

```promql
100 - (avg by(instance)(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```

Memory Usage

```promql
(node_memory_MemTotal_bytes-node_memory_MemAvailable_bytes)/node_memory_MemTotal_bytes*100
```

Request Rate

```promql
rate(http_requests_total[5m])
```

Error Rate

```promql
rate(http_requests_total{status=~"5.."}[5m])
```

---

## Verification

✓ Metrics collected

✓ Logs collected

✓ Traces collected

✓ Grafana dashboards created

✓ Sample application monitored

---

## Cleanup

```bash
helm uninstall alloy -n monitoring
helm uninstall tempo -n monitoring
helm uninstall loki -n monitoring
helm uninstall monitoring -n monitoring
kubectl delete namespace monitoring
```
