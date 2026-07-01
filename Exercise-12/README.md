# Node NotReady Investigation – DiskPressure Incident

## Overview

This lab simulates a production Kubernetes node failure where a node becomes **NotReady** due to **DiskPressure** caused by excessive container log consumption.

The objective is to investigate the node, identify the root cause, safely recover the node, and validate that it returns to a healthy state.

---

## Incident

**Node Status**

```text
kubectl get nodes

NAME                     STATUS
node-lab-control-plane   NotReady
```

**Node Conditions**

```text
DiskPressure=True
```

**System Journal**

```text
no space left on device
```

**Disk Usage**

```text
du -sh /var/log/containers/*

95G /var/log/containers
```

---

## Objectives

* Investigate the `NotReady` node.
* Identify the cause of `DiskPressure`.
* Analyze disk utilization.
* Recover the node safely.
* Verify node health after recovery.

---

## Environment

* Kubernetes (Kind Cluster)
* Docker Desktop
* kubectl
* BusyBox (Log Generator)

---

## Project Structure

```text
task_12/
└── logger.yaml
```

---

## Deployment

Create the Kind cluster.

```bash
kind create cluster --name node-lab
```

Deploy the log generator.

```bash
kubectl apply -f logger.yaml
```

Verify resources.

```bash
kubectl get nodes
kubectl get pods
```

---

## Investigation Steps

### 1. Check Node Status

```bash
kubectl get nodes
```

### 2. Describe the Node

```bash
kubectl describe node node-lab-control-plane
```

Review node conditions, paying attention to:

* DiskPressure
* MemoryPressure
* PIDPressure

### 3. Access the Node

```bash
docker exec -it node-lab-control-plane bash
```

### 4. Check Disk Usage

```bash
df -h
```

### 5. Identify Large Directories

```bash
du -sh /var/log/*
```

### 6. Inspect Container Logs

```bash
du -sh /var/log/containers/*
```

### 7. Locate Large Log Files

```bash
find /var/log/containers -type f -exec ls -lh {} \;
```

---

## Root Cause Analysis

| Investigation  | Result                                 |
| -------------- | -------------------------------------- |
| Node Status    | NotReady                               |
| DiskPressure   | True                                   |
| Disk Usage     | High                                   |
| Container Logs | Excessive Growth                       |
| Root Cause     | Disk space exhausted by container logs |

---

## Resolution

Clear oversized container logs.

```bash
truncate -s 0 /var/log/containers/*.log
```

Verify disk usage.

```bash
df -h
du -sh /var/log/containers
```

Confirm node health.

```bash
kubectl get nodes
```

Expected output:

```text
NAME                     STATUS
node-lab-control-plane   Ready
```

---

## Production Recovery Workflow

```text
Node NotReady
        │
        ▼
Describe Node
        │
        ▼
Identify DiskPressure
        │
        ▼
Check Disk Usage
        │
        ▼
Inspect Container Logs
        │
        ▼
Locate Large Log Files
        │
        ▼
Clean Up Logs
        │
        ▼
Verify Node Status
        │
        ▼
Node Ready
```

---

## Key Learnings

* Investigated a Kubernetes `NotReady` node.
* Diagnosed `DiskPressure` using Kubernetes and Linux commands.
* Analyzed node disk utilization.
* Identified excessive container logs as the root cause.
* Performed safe log cleanup.
* Validated successful node recovery.
* Applied a production-style troubleshooting workflow for node-level incidents.

---

## Cleanup

Delete the deployment.

```bash
kubectl delete -f logger.yaml
```

Delete the Kind cluster.

```bash
kind delete cluster --name node-lab
```

---

**Note:** In a Kind cluster, reproducing an actual `DiskPressure=True` condition is difficult because it depends on the kubelet's eviction thresholds and the host system's available disk space. This lab focuses on practicing the same investigation and recovery workflow used in production Kubernetes environments.
