# CrashLoopBackOff Investigation – Kubernetes Incident Lab

## Overview

This lab simulates a production Kubernetes incident where the `payment-service` application enters a **CrashLoopBackOff** state because it cannot connect to a PostgreSQL database.

The objective is to investigate the failure using standard Kubernetes troubleshooting techniques, identify the root cause, and restore the application.

---

## Scenario

**Incident**

```text
kubectl get pods

payment-service   CrashLoopBackOff
```

**Application Logs**

```text
panic:
dial tcp postgres:5432
connection refused
```

**Events**

```text
Back-off restarting failed container
```

---

## Objectives

* Investigate the cause of `CrashLoopBackOff`.
* Determine whether the issue is related to:

  * DNS Resolution
  * Database Availability
  * Kubernetes Secret
* Identify the root cause.
* Restore the application.

---

## Environment

* Kubernetes (Kind Cluster)
* Docker Desktop
* kubectl
* PostgreSQL
* BusyBox (Application Simulation)

---

## Project Structure

```text
crashloop-lab/
│
├── postgres.yaml
├── postgres-service.yaml
└── payment.yaml
```

---

## Deployment

```bash
kubectl create namespace crashlab

kubectl apply -f postgres.yaml
kubectl apply -f postgres-service.yaml
kubectl apply -f payment.yaml
```

---

## Incident Simulation

Delete the PostgreSQL deployment to simulate a database outage.

```bash
kubectl delete deployment postgres -n crashlab
```

The application will repeatedly fail to connect to the database and enter the `CrashLoopBackOff` state.

---

## Investigation Steps

### Check Pod Status

```bash
kubectl get pods -n crashlab
```

### Review Application Logs

```bash
kubectl logs <payment-pod> -n crashlab --previous
```

### Describe the Pod

```bash
kubectl describe pod <payment-pod> -n crashlab
```

### Verify Service

```bash
kubectl get svc -n crashlab
```

### Verify Endpoints

```bash
kubectl get endpoints -n crashlab
```

### Verify Database Pod

```bash
kubectl get pods -n crashlab
```

### Verify DNS Resolution (Optional)

```bash
kubectl run debug --rm -it --image=busybox -n crashlab -- sh

nslookup postgres
```

---

## Root Cause Analysis

| Investigation      | Result                                                    |
| ------------------ | --------------------------------------------------------- |
| DNS Resolution     | Successful                                                |
| Kubernetes Service | Available                                                 |
| Service Endpoints  | No Active Endpoints                                       |
| PostgreSQL Pod     | Not Running                                               |
| Secrets            | No Issues Found                                           |
| Root Cause         | Database unavailable, causing application startup failure |

---

## Resolution

Restore the PostgreSQL deployment.

```bash
kubectl apply -f postgres.yaml

kubectl rollout restart deployment payment-service -n crashlab
```

Verify application status.

```bash
kubectl get pods -n crashlab
```

Expected Output

```text
postgres           Running
payment-service    Running
```

---

## Key Learnings

* Understand the `CrashLoopBackOff` lifecycle.
* Troubleshoot Kubernetes workloads using logs and events.
* Differentiate between DNS, Service, Secret, and Database failures.
* Validate Kubernetes Services and Endpoints.
* Perform structured root cause analysis (RCA).
* Apply production-style Kubernetes troubleshooting practices.

---

## Production Troubleshooting Workflow

```text
CrashLoopBackOff
        │
        ▼
Check Pod Status
        │
        ▼
Inspect Application Logs
        │
        ▼
Describe Pod Events
        │
        ▼
Verify Service
        │
        ▼
Check Endpoints
        │
        ▼
Verify Database Pod
        │
        ▼
Identify Root Cause
        │
        ▼
Restore Service
        │
        ▼
Validate Application Health
```

---

## Cleanup

```bash
kubectl delete namespace crashlab

kind delete cluster --name crashlab
```

---

**Outcome:** Successfully investigated a production-style Kubernetes `CrashLoopBackOff` incident, identified the database connectivity issue, and restored application availability using a structured troubleshooting methodology.
