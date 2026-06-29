# Exercise 9 – Prometheus Monitoring Failure

## Objective

Troubleshoot a Prometheus monitoring issue where application metrics are no longer visible in Grafana.

---

## Incident Summary

### Symptoms

* Grafana dashboards display **No Data**
* Prometheus target for `payment-service` is **DOWN**
* Prometheus logs show:

```text
context deadline exceeded
```

### Configuration

#### ServiceMonitor

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: payment-service
spec:
  selector:
    matchLabels:
      app: payment-service
  endpoints:
  - port: metrics
    interval: 15s
```

#### Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: payment-service
spec:
  selector:
    app: payment-service
  ports:
  - name: prometheus
    port: 9100
    targetPort: metrics
```

---

# Architecture

```text
Application Pod
      │
      ▼
   Service
      │
      ▼
 ServiceMonitor
      │
      ▼
 Prometheus
      │
      ▼
   Grafana
```

Prometheus discovers targets through the ServiceMonitor.

The ServiceMonitor references a specific Service port name.

If the port names do not match, Prometheus cannot scrape metrics.

---

# Root Cause Analysis

The ServiceMonitor expects:

```yaml
port: metrics
```

The Service exposes:

```yaml
name: prometheus
```

Because the ServiceMonitor references a port named `metrics`, Prometheus searches for that port on the Service.

Since the Service only exposes a port named `prometheus`, Prometheus cannot locate the endpoint and the target becomes unavailable.

---

# Investigation Steps

## 1. Check ServiceMonitor Configuration

```bash
kubectl get servicemonitor payment-service -o yaml
```

Verify:

```yaml
endpoints:
- port: metrics
```

---

## 2. Check Service Configuration

```bash
kubectl get svc payment-service -o yaml
```

Verify:

```yaml
ports:
- name: prometheus
```

---

## 3. Compare Configurations

| Component      | Port Name  |
| -------------- | ---------- |
| ServiceMonitor | metrics    |
| Service        | prometheus |

Mismatch detected.

---

## 4. Verify Prometheus Targets

Open Prometheus:

```text
http://localhost:9090/targets
```

Observed status:

```text
payment-service  DOWN
```

Error:

```text
context deadline exceeded
```

---

# Solution

Update the Service port name to match the ServiceMonitor configuration.

## Correct Service Configuration

```yaml
apiVersion: v1
kind: Service
metadata:
  name: payment-service
spec:
  selector:
    app: payment-service
  ports:
  - name: metrics
    port: 9100
    targetPort: metrics
```

Apply the changes:

```bash
kubectl apply -f payment-service.yaml
```

---

# Validation

Verify the Service:

```bash
kubectl get svc payment-service -o yaml
```

Expected:

```yaml
ports:
- name: metrics
```

Verify Prometheus targets:

```text
http://localhost:9090/targets
```

Expected status:

```text
payment-service  UP
```

Verify Grafana dashboards:

```text
Metrics visible
No Data error resolved
```

---

# Before Fix

```text
Grafana
   │
   ▼
 No Data

Prometheus
   │
   ▼
 Target DOWN

ServiceMonitor
   │
   ▼
 port: metrics

Service
   │
   ▼
 name: prometheus
```

---

# After Fix

```text
Grafana
   │
   ▼
 Metrics Visible

Prometheus
   │
   ▼
 Target UP

ServiceMonitor
   │
   ▼
 port: metrics

Service
   │
   ▼
 name: metrics
```

---