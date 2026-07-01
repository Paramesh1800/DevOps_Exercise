# Exercise 4 - External Secrets Failure

## Objective

This exercise demonstrates how to securely retrieve secrets from AWS Secrets Manager using External Secrets Operator (ESO) in an Amazon EKS cluster. It also simulates a production incident where an application fails to start because the External Secrets Operator cannot retrieve the secret due to missing AWS IAM permissions.

By the end of this lab, you will be able to:
- Install and configure External Secrets Operator.
- Retrieve secrets from AWS Secrets Manager.
- Configure IAM Roles for Service Accounts (IRSA).
- Inject secrets into Kubernetes Pods.
- Troubleshoot External Secrets synchronization failures.
- Identify whether the issue is related to AWS IAM, Kubernetes, or the secret itself.

--------------------------------------------------------------------

## Architecture

                 AWS Secrets Manager
                         │
                         │
               GetSecretValue API
                         │
                  IAM Role (IRSA)
                         │
                         │
           External Secrets Operator
                         │
               ExternalSecret Resource
                         │
               Kubernetes Secret
                         │
                 Application Pod
                         │
                Environment Variable
                    DB_PASSWORD

--------------------------------------------------------------------

## Prerequisites

- AWS Account
- AWS CLI
- kubectl
- eksctl
- Helm
- PowerShell (Windows)

--------------------------------------------------------------------

## Step 1 - Configure AWS CLI

aws configure

Enter:
AWS Access Key ID
AWS Secret Access Key
Default Region
Output Format

Verify:

aws sts get-caller-identity

--------------------------------------------------------------------

## Step 2 - Create EKS Cluster

eksctl create cluster ^
--name eks-lab ^
--region us-east-1 ^
--version 1.33 ^
--nodegroup-name linux-nodes ^
--node-type t3.medium ^
--nodes 2 ^
--nodes-min 1 ^
--nodes-max 2 ^
--managed

Wait approximately 20 minutes for the cluster to become ACTIVE.

Verify:

kubectl get nodes

--------------------------------------------------------------------

## Step 3 - Associate OIDC Provider

eksctl utils associate-iam-oidc-provider ^
--cluster eks-lab ^
--region us-east-1 ^
--approve

--------------------------------------------------------------------

## Step 4 - Install Helm

helm repo add external-secrets https://charts.external-secrets.io

helm repo update

--------------------------------------------------------------------

## Step 5 - Install External Secrets Operator

helm install external-secrets external-secrets/external-secrets ^
--namespace external-secrets ^
--create-namespace

Verify:

kubectl get pods -n external-secrets

--------------------------------------------------------------------

## Step 6 - Create AWS Secret

Open AWS Console

Secrets Manager

Create Secret

Secret Name

prod/database

Secret Value

DB_PASSWORD=mySuperPassword123

--------------------------------------------------------------------

## Step 7 - Create Project Directory

mkdir external-secrets-lab

cd external-secrets-lab

--------------------------------------------------------------------

## Step 8 - Create Configuration Files

New-Item namespace.yaml -ItemType File

New-Item serviceaccount.yaml -ItemType File

New-Item secretstore.yaml -ItemType File

New-Item externalsecret.yaml -ItemType File

New-Item deployment.yaml -ItemType File

--------------------------------------------------------------------

## namespace.yaml

apiVersion: v1
kind: Namespace
metadata:
  name: demo

--------------------------------------------------------------------

## serviceaccount.yaml

Replace ACCOUNT_ID with your AWS Account ID.

apiVersion: v1
kind: ServiceAccount
metadata:
  name: external-secrets-sa
  namespace: external-secrets
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::<ACCOUNT_ID>:role/external-secrets-role

--------------------------------------------------------------------

## secretstore.yaml

apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: aws-secret-store
  namespace: demo

spec:
  provider:
    aws:
      service: SecretsManager
      region: us-east-1

--------------------------------------------------------------------

## externalsecret.yaml

apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret

metadata:
  name: database-secret
  namespace: demo

spec:

  refreshInterval: 1m

  secretStoreRef:
    name: aws-secret-store
    kind: SecretStore

  target:
    name: app-secret

  data:
  - secretKey: DB_PASSWORD
    remoteRef:
      key: prod/database
      property: DB_PASSWORD

--------------------------------------------------------------------

## deployment.yaml

apiVersion: apps/v1
kind: Deployment

metadata:
  name: payment-app
  namespace: demo

spec:
  replicas: 1

  selector:
    matchLabels:
      app: payment-app

  template:
    metadata:
      labels:
        app: payment-app

    spec:
      containers:
      - name: payment-app
        image: nginx:latest

        env:
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: app-secret
              key: DB_PASSWORD

--------------------------------------------------------------------

## Step 9 - Apply All Resources

kubectl apply -f namespace.yaml

kubectl apply -f serviceaccount.yaml

kubectl apply -f secretstore.yaml

kubectl apply -f externalsecret.yaml

kubectl apply -f deployment.yaml

--------------------------------------------------------------------

## Step 10 - Verify Deployment

kubectl get pods -A

kubectl get ns

kubectl get secret -n demo

kubectl get externalsecret -n demo

kubectl get deployment -n demo

kubectl describe externalsecret database-secret -n demo

kubectl logs deployment/external-secrets -n external-secrets

--------------------------------------------------------------------

## Simulate Production Incident

Remove the following IAM permission from the IAM role attached to the External Secrets Service Account.

secretsmanager:GetSecretValue

Wait approximately one minute.

--------------------------------------------------------------------

## Observe the Failure

Check External Secret

kubectl get externalsecret -n demo

Expected

READY=False

--------------------------------------------------------------------

Describe External Secret

kubectl describe externalsecret database-secret -n demo

Expected

SecretSyncedError

AccessDeniedException

User is not authorized to perform:

secretsmanager:GetSecretValue

--------------------------------------------------------------------

Check Controller Logs

kubectl logs deployment/external-secrets -n external-secrets

Expected

AccessDeniedException

GetSecretValue

Permission Denied

--------------------------------------------------------------------

Check Application Logs

kubectl logs deployment/payment-app -n demo

Expected

FATAL:

Database password not found

Environment Variable DB_PASSWORD missing

--------------------------------------------------------------------

## Root Cause Analysis

Application Pod
      │
      ▼
Needs Kubernetes Secret
      │
      ▼
External Secret should create Kubernetes Secret
      │
      ▼
External Secrets Operator contacts AWS Secrets Manager
      │
      ▼
AWS IAM denies GetSecretValue request
      │
      ▼
Secret synchronization fails
      │
      ▼
Kubernetes Secret is never created
      │
      ▼
Application cannot read DB_PASSWORD
      │
      ▼
Application startup fails

--------------------------------------------------------------------

## Investigation

1. Verify Pod Status

kubectl get pods -n demo

2. View Pod Logs

kubectl logs deployment/payment-app -n demo

3. Verify Kubernetes Secret

kubectl get secret -n demo

4. Check External Secret

kubectl get externalsecret -n demo

5. Describe External Secret

kubectl describe externalsecret database-secret -n demo

6. View External Secrets Controller Logs

kubectl logs deployment/external-secrets -n external-secrets

7. Verify IAM Policy attached to the IRSA Role

--------------------------------------------------------------------

## Determine the Root Cause

AWS Issue
YES

Reason:
IAM Role does not have secretsmanager:GetSecretValue permission.

Kubernetes Issue
NO

All Kubernetes resources are healthy.

Secret Issue
NO

The secret exists in AWS Secrets Manager.

The issue is insufficient IAM permissions preventing the External Secrets Operator from reading the secret.

--------------------------------------------------------------------

## Resolution

Attach the following IAM permission back to the IRSA role.

secretsmanager:GetSecretValue

Wait for the next synchronization.

Verify

kubectl get externalsecret -n demo

Expected

READY=True

Verify Secret

kubectl get secret -n demo

Restart the application

kubectl rollout restart deployment payment-app -n demo

Verify logs

kubectl logs deployment/payment-app -n demo

Application should start successfully.

--------------------------------------------------------------------

## Cleanup

Delete all Kubernetes resources

kubectl delete -f deployment.yaml

kubectl delete -f externalsecret.yaml

kubectl delete -f secretstore.yaml

kubectl delete -f serviceaccount.yaml

kubectl delete -f namespace.yaml

Delete the EKS cluster

eksctl delete cluster ^
--name eks-lab ^
--region us-east-1

--------------------------------------------------------------------

## Skills Gained

- Amazon EKS
- External Secrets Operator
- AWS Secrets Manager
- Kubernetes Secrets
- IAM Roles for Service Accounts (IRSA)
- Kubernetes Deployments
- Helm
- IAM Policy Troubleshooting
- Production Incident Investigation
- Root Cause Analysis
- Kubernetes Logging and Debugging
