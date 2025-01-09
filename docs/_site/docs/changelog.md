This document provides a detailed history of changes, updates, and improvements made to the project. Changes are documented using **semantic versioning**.

---

## Version v0.4.1/2b - Code Support (2025-01-08)

### Added
- Modifying using deployment to statefulset, to avoid EBS attachment issues on restart
- Clean new Service Image with Debug logs
- Enabled Flags to control each scanning explicitly, to avoid re-scanning of large resources
- Added more cleaning of the ra data in the traning job

---

## Version v0.4.0b - Code Support (2024-12-26)

### Added
- Adding Github Integration Support
- Added additional preprocessing to context
- Optimize indexing and embedding of raw context

---

## Version v0.3.0b - Document Support (2024-12-19)

### Added
- Updated Helm Chart and Terraform Scripts to use separate volumes for job and service pods respectively.
- Adding Confluence and Google Docs Integration Support

---

## Version v0.2.0b - Databricks Support (2024-12-11)

### Added
- Helm chart for deploying a chicory job and inference service on Kubernetes.
- Instructions for deploying and managing resources with Argo CD.
- Comprehensive `README.md` with setup and deployment instructions.
- Added support for Databricks catalog/schema integration

---

## Version v0.1.0b - Initial Release (2024-11-27)

### Added
- Initial Terraform configurations for setting up AWS resources:
  - VPC, Subnets, Route Tables
  - EKS Cluster and Node Groups
  - Security Groups and IAM Roles
- Helm chart for deploying a dummy service on Kubernetes.
- Instructions for deploying and managing resources with Argo CD.
- Comprehensive `README.md` with setup and deployment instructions.

### Notes
- Tested on Kubernetes version 1.23+ and AWS region `us-west-2`.
- Helm chart defaults to deploying a `dummy-service` container.
- Argo CD setup is optional but included for advanced deployment management.

---

## Versioning Guidelines

### Semantic Versioning (MAJOR.MINOR.PATCH)
1. **MAJOR**: Incompatible changes or major new features.
2. **MINOR**: Backward-compatible functionality enhancements.
3. **PATCH**: Backward-compatible bug fixes or documentation updates.
