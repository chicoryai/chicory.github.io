---
layout: page
title: "Chicory Deployment Guide"
date:   2025-01-07 00:16:37 -0800
categories: jekyll update
---

# Setup Instructions

This guide provides detailed instructions to set up AWS resources using Terraform, deploy a dummy service on Kubernetes using a Helm chart, and manage the deployment with Argo CD.


---

## Versioning

- **Terraform Configuration Version**: v1.9.8
- **Helm Chart Version**: v3.16.3
- **Compatible Kubernetes Version**: v1.31+

Refer to the [changelog](./changelog.md) for details about updates and changes in each version.

---

## Prerequisites

Before starting, ensure the following tools are installed:
1. **Terraform**: [Installation Guide](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
2. **kubectl**: [Installation Guide](https://kubernetes.io/docs/tasks/tools/)
3. **Helm**: [Installation Guide](https://helm.sh/docs/intro/install/)

---

## Accessing AWS ECR docker image (To be done by Chicory team)

#### 1. Validation of ECR Policy JSON: Updating Chicory's ECR permission with user-prod-account details
```bash
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::<user-prod-account-id>:role/<role-name>"
            },
            "Action": [
                "ecr:BatchCheckLayerAvailability",
                "ecr:BatchGetImage",
                "ecr:GetDownloadUrlForLayer"
            ]
        }
    ]
} 
```

### 2. ECR Repository Details: Chicory will share ECR repo details 
```bash
<Chicory-prod-id>.dkr.ecr.us-west-2.amazonaws.com/chicory/discovery-inference:latest
<Chicory-prod-id>.dkr.ecr.us-west-2.amazonaws.com/chicory/discovery-training:latest
```
---

## Manual Pre-requisite Steps

These steps must be completed before running Terraform:

### 1. AWS Environment Setup
- Ensure you have an AWS account with sufficient permissions to manage EKS, VPC, subnets, route tables, and certificates.
- Configure the AWS CLI for authentication:
  ```bash
  aws configure --profile <profile-name>
  ```

### 2. [Optional] Obtain an SSL Certificate (Optional, for HTTPS)
- Use AWS Certificate Manager to request a certificate for your domain:
    ```bash
    aws acm request-certificate --domain-name <your-domain>
    ```
- Validate the certificate using DNS or email verification.

### 3. [Optional] Create a Route 53 Hosted Zone
- If using a custom domain name, set up a hosted zone in Route 53 and link it to the VPC.

### 4. Enable Kubernetes Access
- Install `kubectl` and `eksctl`:
    ```bash
    brew install kubectl eksctl
    ```
- If not using Terraform for EKS, create a cluster manually:
    ```bash
    eksctl create cluster --name <cluster-name> --region us-west-2 --nodegroup-name <cluster-name>-node-group
    ```
---

## Steps to Execute

### 1. Update kubectl context and create chicory ns
```bash
aws eks --region <region> update-kubeconfig --name <cluster-name>
kubectl create namespace chicory-ai
```

### 2. Create s3 bucket, if not using the terraform
```bash
aws s3 mb chicory-agent-api-bucket --region <region>
```
* Make sure to provide access to EKS cluster for training job to persist data
1. Either, using service role, refer: https://docs.aws.amazon.com/eks/latest/userguide/using-service-linked-roles.html
2. or, pass ENV to training job:
    AWS_ACCESS_KEY_ID: "aws-access-id for s3 access in case iam & service-role is not setup"
    AWS_SECRET_ACCESS_KEY: "aws-secret-key for s3 access in case iam & service-role is not setup"

You can leverage shared terraform script, for the same:
#### 1. Edit Variables
- Update the `terraform/prod.tfvars` file with required values:
  - `region`: Target region
  - `app_name`: App Name. Default: "chicory-agent-api" | <cluster-name>
  - `eks_cluster_name`: Cluster Name. <cluster-name>

#### 2. Initialize and Apply Terraform
- Navigate to the s3-terraform/ directory:
```bash
terraform init
terraform validate
terraform plan -var-file=prod.tfvars
terraform apply -var-file=prod.tfvars
```
- Confirm the changes to provision the infrastructure.
    * Debugging Steps:
        - Verify the Service Account for EBS CSI: Check the service account used by the EBS CSI controller
        ```bash
        kubectl get sa ebs-csi-controller-sa -n kube-system -o yaml
        ```
        - Create an IAM Role for EBS CSI Driver:
        ```bash
        aws iam create-role \
            --role-name EBSCSIDriverRole \
            --assume-role-policy-document '{
                "Version": "2012-10-17",
                "Statement": [
                {
                    "Effect": "Allow",
                    "Principal": {
                    "Service": "eks.amazonaws.com"
                    },
                    "Action": "sts:AssumeRole"
                }
                ]
            }'
        ```
        - Attach the `AmazonEBSCSIDriverPolicy`:
        ```bash
        aws iam attach-role-policy \
            --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
            --role-name EBSCSIDriverRole
        ```
        - Annotate the Service Account: Annotate the EBS CSI controller service account to use the newly created IAM role:
        ```bash
        kubectl annotate sa ebs-csi-controller-sa -n kube-system \
          eks.amazonaws.com/role-arn=arn:aws:iam::<account-id>:role/EBSCSIDriverRole
        ```

### 3. Deploy Chicory Resources with Helm
#### 1. Deploy the Helm Chart:

Required Secrets/ENVs:
* OPENAI_API_KEY
* DATABRICKS_ACCESS_TOKEN
* DATABRICKS_HOST
* DATABRICKS_HTTP_PATH
* DATABRICKS_CATALOG
* DATABRICKS_SCHEMA
* SLACK_BOT_ID
* SLACK_SIGNING_SECRET
* SLACK_BOT_TOKEN
* PROJECT
* S3_BUCKET
* ...

   Example snippet for `values.yaml`:
   ```bash
   secrets:
     OPENAI_API_KEY: "<your-api-key>"                    # API key for OpenAI integration
     DATABRICKS_ACCESS_TOKEN: "<your-databricks-token>"  # API token for Databricks
     DATABRICKS_HOST: "<your-databricks-host>"           # URL of your Databricks workspace
     DATABRICKS_HTTP_PATH: "<your-http-path>"            # HTTP path for your Databricks cluster or SQL endpoint
     DATABRICKS_CATALOG: "<your-databricks-catalog>"     # Databricks catalog name
     DATABRICKS_SCHEMA: "<your-databricks-schema>"       # Databricks schema name
     SLACK_BOT_ID: "<your-slack-bot-id>"                 # Unique ID of the Slack bot
     SLACK_SIGNING_SECRET: "<your-slack-signing-secret>" # Signing secret for validating Slack requests
     SLACK_BOT_TOKEN: "<your-slack-bot-token>"           # API token for the Slack bot.
     ...
   ```

    ```bash
    cd helm
    helm install chicory-app ./ -n chicory-ai -f values.yaml
    ```

#### 3. Verify Deployment:

- Checking services on kubernetes
```bash
kubectl get all -n chicory-ai
```

- Access slack endpoint @ https://external-ip
```bash
kubectl get svc discovery-api -n chicory-ai
```

- Access cron job logs
```bash
kubectl get pods -n chicory-ai | grep training-job-sync  # First find the job pod
kubectl logs <pod-name> -n chicory-ai  # Then get the logs using the pod name
```

### 5. [REQUIRED] Restart your discovery svc after job training completes
```bash
kubectl rollout restart deployment discovery-api -n chicory-ai
```

---

## Summary
This guide ensures that the necessary AWS resources and Kubernetes infrastructure are in place, the dummy service is deployed, and external integrations are supported.

For further assistance, refer to the documentation folder or contact the support team.


---

# Appendix

## Steps to Execute, for creating your own EKS Cluster
### 1. Edit Variables
- Update the `terraform/prod.tfvars` file with required values:
  - `region`: Target region
  - `app_name`: App Name. Default: "chicory-agent-api" | <cluster-name>
  - `desired_node_count`: Desired Kubernetes Node Count
  - `node_group_instance_type`: Cluster Node Group Instance. Requires memory.
  - `max_node_count`: Maximum Node Count
  - `min_node_count`: Minimum Node Count
  - `cert`: (Optional) ARN for SSL certificate if using HTTPS.

### 2. Initialize and Apply Terraform
- Navigate to the terraform/ directory:
```bash
terraform init
terraform validate
terraform plan -var-file=prod.tfvars
terraform apply -var-file=prod.tfvars
```
- Confirm the changes to provision the infrastructure.

### 3. Ensure EBS CSI Driver is Installed
After configuring the current kube context
```bash
helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver
helm repo update
helm install aws-ebs-csi-driver aws-ebs-csi-driver/aws-ebs-csi-driver \
  --namespace kube-system \
  --set enableVolumeScheduling=true \
  --set enableVolumeResizing=true \
  --set enableVolumeSnapshot=true
# Verify
kubectl get pod -n kube-system -l "app.kubernetes.io/name=aws-ebs-csi-driver,app.kubernetes.io/instance=aws-ebs-csi-driver"
```
