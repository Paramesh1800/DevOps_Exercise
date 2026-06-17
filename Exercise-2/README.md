# Exercise 2 – IAM / IRSA Failure Analysis

## Incident Summary

An application running inside an Amazon EKS cluster suddenly lost access to DynamoDB. The application logs show an authorization failure when attempting to perform a `GetItem` operation on the `customer-data` table.

### Error Log

```text
2026-05-10T08:12:13Z ERROR

botocore.exceptions.ClientError:
An error occurred (AccessDeniedException)
when calling the GetItem operation:

User:
arn:aws:sts::123456789012:assumed-role/eks-nodegroup-role

is not authorized to perform:
dynamodb:GetItem

on resource:
arn:aws:dynamodb:ap-south-1:123456789012:table/customer-data
```

---

## Architecture

```text
Pod
 ↓
ServiceAccount
 ↓
IAM Role (IRSA)
 ↓
DynamoDB
```

The application is expected to access DynamoDB using IAM Roles for Service Accounts (IRSA).

---

# Investigation

## Observation

The error message indicates that the request is being made using:

```text
arn:aws:sts::123456789012:assumed-role/eks-nodegroup-role
```

instead of the IAM role assigned through IRSA.

This confirms that the application is using the EKS worker node IAM role rather than the ServiceAccount IAM role.

---

# Why the Node Role Is Being Used

In Amazon EKS, if IRSA is not functioning correctly, the AWS SDK attempts to obtain credentials from the EC2 Instance Metadata Service (IMDS).

Credential resolution order:

```text
IRSA Credentials
       ↓
Web Identity Token
       ↓
Node IAM Role (Fallback)
```

Since IRSA failed, the SDK automatically fell back to the node IAM role:

```text
eks-nodegroup-role
```

The node role does not have permission to perform:

```text
dynamodb:GetItem
```

which resulted in the AccessDeniedException.

---

# Possible Causes of IRSA Failure

## 1. Incorrect ServiceAccount Configuration

The pod may not be using the intended ServiceAccount.

Verification:

```bash
kubectl describe pod <pod-name>
```

Expected:

```yaml
serviceAccountName: customer-sa
```

---

## 2. Missing IAM Role Annotation

The ServiceAccount may not contain the IRSA role annotation.

Verification:

```bash
kubectl get sa customer-sa -o yaml
```

Expected:

```yaml
annotations:
  eks.amazonaws.com/role-arn: arn:aws:iam::123456789012:role/customer-irsa-role
```

---

## 3. Incorrect IAM Trust Relationship

The IAM role trust policy may not match the ServiceAccount namespace or name.

Example:

```json
{
  "Effect": "Allow",
  "Principal": {
    "Federated": "arn:aws:iam::123456789012:oidc-provider/oidc.eks.ap-south-1.amazonaws.com/id/XXXXX"
  },
  "Action": "sts:AssumeRoleWithWebIdentity",
  "Condition": {
    "StringEquals": {
      "oidc.eks.ap-south-1.amazonaws.com/id/XXXXX:sub":
      "system:serviceaccount:default:customer-sa"
    }
  }
}
```

Any mismatch prevents role assumption.

---

## 4. Missing OIDC Provider

IRSA requires an IAM OIDC provider associated with the EKS cluster.

Verification:

```bash
aws iam list-open-id-connect-providers
```

If not present:

```bash
eksctl utils associate-iam-oidc-provider \
--cluster my-cluster \
--approve
```

---

## 5. Pod Not Restarted

Even after fixing ServiceAccount annotations, existing pods continue using old credentials.

A deployment restart is required.

---

# Verification Steps

## Check Pod ServiceAccount

```bash
kubectl describe pod <pod-name>
```

Verify:

```text
Service Account: customer-sa
```

---

## Check ServiceAccount Annotation

```bash
kubectl get sa customer-sa -o yaml
```

Verify:

```yaml
eks.amazonaws.com/role-arn
```

exists.

---

## Check Environment Variables Inside Pod

```bash
kubectl exec -it <pod-name> -- env | grep AWS
```

Expected:

```text
AWS_ROLE_ARN
AWS_WEB_IDENTITY_TOKEN_FILE
```

---

## Check OIDC Provider

```bash
aws eks describe-cluster \
--name my-cluster \
--query cluster.identity.oidc.issuer
```

```bash
aws iam list-open-id-connect-providers
```

---

## Check Current Caller Identity

```bash
kubectl exec -it <pod-name> -- aws sts get-caller-identity
```

Expected Result:

```text
arn:aws:sts::123456789012:assumed-role/customer-irsa-role
```

Not:

```text
arn:aws:sts::123456789012:assumed-role/eks-nodegroup-role
```

---

# Solution

## Step 1: Annotate the ServiceAccount

```bash
kubectl annotate serviceaccount customer-sa \
eks.amazonaws.com/role-arn=arn:aws:iam::123456789012:role/customer-irsa-role
```

---

## Step 2: Verify Trust Relationship

Ensure the IAM role trust policy contains:

```text
Correct OIDC Provider
Correct Namespace
Correct ServiceAccount Name
```

---

## Step 3: Attach DynamoDB Permissions

IAM Policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem"
      ],
      "Resource": [
        "arn:aws:dynamodb:ap-south-1:123456789012:table/customer-data"
      ]
    }
  ]
}
```

Attach the policy to:

```text
customer-irsa-role
```

---

## Step 4: Restart Application Pods

```bash
kubectl rollout restart deployment customer-app
```

---

# Root Cause Analysis (RCA)

## Root Cause

The application was expected to authenticate using IAM Roles for Service Accounts (IRSA). However, IRSA failed due to a configuration issue such as:

* Missing ServiceAccount annotation
* Incorrect trust policy
* Missing OIDC provider
* Pod using the wrong ServiceAccount

As a result, the AWS SDK fell back to the EKS node IAM role (`eks-nodegroup-role`).

The node role did not have permission to perform:

```text
dynamodb:GetItem
```

causing the request to fail.

---

## Impact

* Application could not read data from DynamoDB.
* Customer-related operations dependent on DynamoDB failed.
* Application functionality was partially unavailable.

---

## Resolution

* Verified ServiceAccount configuration.
* Corrected IRSA role mapping.
* Validated IAM trust relationship.
* Ensured DynamoDB permissions were attached to the IRSA role.
* Restarted application pods to obtain new credentials.

---

# Conclusion

The incident occurred because the application used the EKS node IAM role instead of the IAM role configured through IRSA. Correcting the IRSA configuration and ensuring proper DynamoDB permissions restored application access and resolved the issue.
