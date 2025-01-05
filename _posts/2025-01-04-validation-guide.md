---
layout: post
title: "Chicory Validation Guide"
date: 2025-01-04
---

# Chicory Training and Inference Validation

1. Restarted inference service after last training completes
```sh
kubectl rollout restart deployment discovery-api -n chicory-ai
```

2. Verifying the Success of the S3 data downloads
```sh
kubectl get svc discovery-api -n chicory-ai
kubectl get pods -l app=discovery-api -n chicory-ai

kubectl exec -n chicory-ai -it <pod> -- ls -l /app/data
```

3. Capture logs of an inference event
```sh
kubectl logs -f <pod> -n chicory-ai >> inf.log 2>&1
```

4. Verifying the Success of the Databricks Connection
* Training Phase: Once the training process is complete, validate the connection by reviewing your Databricks Query History for executed queries, such as `LISTING`, `SHOW TABLES` or more.
* Inference Phase: After running a query, check the query history in your Databricks workspace management to confirm that the related query was triggered and executed successfully.
