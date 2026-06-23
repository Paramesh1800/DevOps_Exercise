# DynamoDB Customer API Service

A simple containerized Flask REST API that interacts with AWS DynamoDB to perform CRUD operations on a `Customer` database. This application is configured to run locally, within a Docker container, and deployed on a Kubernetes cluster.

## Project Structure

```text
Exercise-24/
└── dynamodb-app/
    ├── app.py             # Flask application code with DynamoDB integration
    ├── Dockerfile         # Configuration to containerize the Flask application
    ├── requirements.txt   # Python dependencies (flask, boto3, gunicorn)
    ├── deployment.yaml    # Kubernetes Deployment manifest
    └── service.yaml       # Kubernetes LoadBalancer Service manifest
```

---

## API Endpoints

| Method | Endpoint | Description | Sample Payload (JSON) |
| :--- | :--- | :--- | :--- |
| **GET** | `/` | Health check endpoint | N/A |
| **POST** | `/customer` | Create a new customer | `{"customer_id": "1", "name": "John Doe", "email": "john@example.com"}` |
| **GET** | `/customer/<customer_id>` | Retrieve a customer profile | N/A |
| **PUT** | `/customer/<customer_id>` | Update a customer's name and email | `{"name": "John Smith", "email": "john.smith@example.com"}` |

---

## Local Development Setup

### Prerequisites
* Python 3.11+
* AWS credentials configured locally (via `aws configure`)

### 1. Install Dependencies
```bash
cd dynamodb-app
pip install -r requirements.txt
```

### 2. Configure AWS Environment
Make sure you have an active DynamoDB table named `Customer` (or configured via environment variables if updated) with a Partition Key named `customer_id` (String).

### 3. Run the Application
```bash
python app.py
```
The API will be available at `http://localhost:5000`.

---

## Containerization (Docker)

### 1. Build the Docker Image
```bash
docker build -t dynamodb-app:latest ./dynamodb-app
```

### 2. Run the Container
Pass AWS credentials and configuration via environment variables:
```bash
docker run -p 5000:5000 \
  -e AWS_ACCESS_KEY_ID=your_access_key \
  -e AWS_SECRET_ACCESS_KEY=your_secret_key \
  -e AWS_DEFAULT_REGION=us-east-1 \
  dynamodb-app:latest
```

---

## Kubernetes Deployment

The service is configured to be deployed on a Kubernetes cluster (e.g. Amazon EKS). It relies on IAM Roles for Service Accounts (IRSA) via the service account `dynamodb-sa` to securely authenticate with AWS DynamoDB.

### 1. Apply Kubernetes Manifests
```bash
kubectl apply -f dynamodb-app/deployment.yaml
kubectl apply -f dynamodb-app/service.yaml
```

### 2. Verify Deployment
```bash
kubectl get pods -l app=dynamodb-app
kubectl get service dynamodb-app-service
```
