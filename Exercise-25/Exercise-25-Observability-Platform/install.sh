#!/bin/bash

# Add repositories
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Create namespace
kubectl create namespace monitoring

# Install kube-prometheus-stack (Prometheus + Grafana)
helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring

# Install Loki
helm install loki grafana/loki-stack -n monitoring

# Install Tempo
helm install tempo grafana/tempo -n monitoring

# Install Alloy
helm install alloy grafana/alloy -n monitoring
