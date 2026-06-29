# DynamoDB Customer API Service (EKS + IRSA Deployment)

A containerized Flask REST API that performs CRUD operations on an AWS DynamoDB table and is deployed on an Amazon EKS cluster using IAM Roles for Service Accounts (IRSA) for secure authentication.

---

## Project Structure

```
Exercise-24/
└── dynamodb-app/
    ├── app.py
    ├── Dockerfile
    ├── requirements.txt
    ├── deployment.yaml
    └── service.yaml
```

---

## API Endpoints

| Method | Endpoint       | Description     |
| ------ | -------------- | --------------- |
| GET    | /              | Health check    |
| POST   | /customer      | Create customer |
| GET    | /customer/<id> | Get customer    |
| PUT    | /customer/<id> | Update customer |

---

## AWS Architecture

```
User
 ↓
LoadBalancer Service
 ↓
EKS Pod (Flask App)
 ↓
ServiceAccount (IRSA)
 ↓
IAM Role
 ↓
DynamoDB Table (Customer)
```

---

## Prerequisites

* AWS Account with credits
* EKS Cluster created
* kubectl configured
* Docker installed
* AWS CLI configured

---

## 1. Build Docker Image

```
docker build -t dynamodb-app .
```

---

## 2. Push to ECR

```
docker tag dynamodb-app:latest <account>.dkr.ecr.us-east-1.amazonaws.com/dynamodb-app:latest

docker push <account>.dkr.ecr.us-east-1.amazonaws.com/dynamodb-app:latest
```

---

## 3. EKS Deployment

```
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

---

## 4. IRSA Setup (Important)

### Create IAM Policy

* DynamoDB: GetItem, PutItem, UpdateItem

### Enable OIDC

```
eksctl utils associate-iam-oidc-provider --cluster dynamodb-eks --region us-east-1 --approve
```

### Create ServiceAccount with IAM Role

```
eksctl create iamserviceaccount \
  --name dynamodb-sa \
  --namespace default \
  --cluster dynamodb-eks \
  --attach-policy-arn arn:aws:iam::<account>:policy/DynamoDBCustomerPolicy \
  --approve
```

---

## 5. Verify Deployment

```
kubectl get pods
kubectl get svc
kubectl get nodes
```

---

## 6. Test API (LoadBalancer URL)

### Create Customer

```
curl -X POST http://<ELB>/customer \
-H "Content-Type: application/json" \
-d '{"customer_id":"1","name":"John","email":"john@example.com"}'
```

### Get Customer

```
curl http://<ELB>/customer/1
```

### Update Customer

```
curl -X PUT http://<ELB>/customer/1 \
-H "Content-Type: application/json" \
-d '{"name":"John Smith","email":"johnsmith@example.com"}'
```

---

## Key Learning

* Kubernetes Deployment on EKS
* Docker containerization
* AWS DynamoDB integration
* IAM Roles for Service Accounts (IRSA)
* Secure AWS access without credentials

---

## Security Note

❌ No AWS access keys used in application
❌ No credentials stored in containers
✅ Uses IRSA for temporary AWS permissions
