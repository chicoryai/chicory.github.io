---
title: Getting Started
tags: 
 - aws
 - terraform
 - github
---

# Getting Started

This guide provides detailed steps for integrating your infrastructure with various platforms, including Databricks, GitHub, Confluence, and Slack. The goal is to ensure the services can perform API requests for reading data, accessing repositories, exporting documents, and interacting with users.

## 1. **AWS Infrastructure Setup**

- **Terraform**: We will provide Terraform scripts to deploy the necessary infrastructure.
- **Required Services**:
    - **EKS (Elastic Kubernetes Service)**: For managing containerized applications.
    - **S3 (Simple Storage Service)**: For storing data and logs.
    - **API Gateway**: To manage APIs for service communication.
    - **VPC (Virtual Private Cloud)**: For secure network isolation.

## 2. **Service Overview**

### **Training Service**
- Responsible for user onboarding and integration.
- Continuously indexes and manages the knowledge graph to ensure the system has up-to-date data relationships and insights.

### **Inference Service**
- An agentic service designed for extracting the correct context from data and performing actions based on user interactions or automated triggers.

## 3. **OpenAI API Access**
- **Agent Access Requirements**: Access frequency and data rate can be customized based on the user’s preferences and data handling needs.
- Use `OPENAI_API_KEY` to enable API interactions.

## 4. **Platform Integration Steps**

[List of supported platforms](integration.md)

---

## **Summary**

Following the above steps will enable your infrastructure and services to integrate seamlessly with Databricks, GitHub, Confluence, and Slack, allowing for data access, document management, and user interactions.
