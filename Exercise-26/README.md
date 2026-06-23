# Exercise 26: S3 Backup Solution

## Objective

Implement a backup and restore solution using Amazon S3 for application files and configuration files.

## Architecture

```text
Local Machine
     │
     ▼
 AWS CLI
     │
     ▼
 Amazon S3 Bucket
     │
     ▼
 Backup Storage
```

## Requirements

* Backup application files to Amazon S3
* Backup configuration files to Amazon S3
* Demonstrate restore process
* Validate successful backup and recovery

---

## Prerequisites

* AWS Account
* Amazon S3 Bucket
* AWS CLI installed and configured
* Valid IAM credentials with S3 access

---

## Project Structure

```text
backup-project
├── app
│   ├── app.py
│   └── requirements.txt
│
├── config
│   └── config.yaml
│
└── restore
```

---

## Step 1: Create S3 Bucket

Created an S3 bucket:

```text
backup-solution-paramesh-2026
```

### Bucket Configuration

* Bucket Type: General Purpose
* Versioning: Enabled
* Block Public Access: Enabled
* Encryption: SSE-S3

---

## Step 2: Create Sample Application Files

### app.py

```python
print("Payment Service Running")
```

### requirements.txt

```text
flask==3.0.0
boto3==1.34.0
```

### config.yaml

```yaml
application:
  name: payment-service
  environment: dev

database:
  host: localhost
  port: 3306
```

---

## Step 3: Configure AWS CLI

Verify AWS CLI installation:

```cmd
aws --version
```

Verify credentials:

```cmd
aws sts get-caller-identity
```

Verify S3 access:

```cmd
aws s3api list-buckets
```

---

## Step 4: Backup Script

### backup.bat

```bat
@echo off

set BUCKET_NAME=backup-solution-paramesh-2026

aws s3 cp backup-project\app s3://%BUCKET_NAME%/backups/app --recursive

aws s3 cp backup-project\config s3://%BUCKET_NAME%/backups/config --recursive

echo Backup Completed Successfully
pause
```

### Execute Backup

```cmd
backup.bat
```

---

## Step 5: Verify Backup

Verify files inside the S3 bucket:

```text
backups/
├── app/
│   ├── app.py
│   └── requirements.txt
│
└── config/
    └── config.yaml
```

---

## Step 6: Restore Script

### restore.bat

```bat
@echo off

set BUCKET_NAME=backup-solution-paramesh-2026

aws s3 cp s3://%BUCKET_NAME%/backups/app backup-project\restore\app --recursive

aws s3 cp s3://%BUCKET_NAME%/backups/config backup-project\restore\config --recursive

echo Restore Completed Successfully
pause
```

### Execute Restore

```cmd
restore.bat
```

---

## Step 7: Simulate Data Loss

Delete original files:

```cmd
del backup-project\app\app.py
del backup-project\app\requirements.txt
del backup-project\config\config.yaml
```

Verify that the files are removed.

---

## Step 8: Restore Original Files

### restore-original.bat

```bat
@echo off

set BUCKET_NAME=backup-solution-paramesh-2026

aws s3 cp s3://%BUCKET_NAME%/backups/app backup-project\app --recursive

aws s3 cp s3://%BUCKET_NAME%/backups/config backup-project\config --recursive

echo Original Files Restored Successfully
pause
```

### Execute Recovery

```cmd
restore-original.bat
```

Verify:

```cmd
dir backup-project\app
dir backup-project\config
```

Expected files:

```text
app.py
requirements.txt
config.yaml
```

---

## Validation

### Backup Validation

* Application files uploaded successfully
* Configuration files uploaded successfully
* Files verified in S3 bucket

### Restore Validation

* Files downloaded successfully
* Deleted files recovered from S3
* Restore process verified

---

## Real-World Use Case

Organizations use Amazon S3 as a backup repository for:

* Application source code
* Configuration files
* Log files
* Database exports
* Disaster recovery

If files are accidentally deleted or a server fails, data can be restored from S3 quickly, reducing downtime and preventing data loss.

---

## Outcome

Successfully implemented an Amazon S3 backup and restore solution.

The solution:

* Backed up application files to S3
* Backed up configuration files to S3
* Demonstrated restore functionality
* Simulated data loss and recovery
* Validated successful disaster recovery workflow
