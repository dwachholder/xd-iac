# XD Web App Kubernetes Setup

This repository contains Kubernetes manifests to deploy the `dwachholder/xd-web-app` Docker image with 2 replicas.

## Files

- `namespace.yaml` - Creates a dedicated namespace for the application
- `deployment.yaml` - Deploys the application with 2 replicas
- `service.yaml` - Exposes the application within the cluster

## Prerequisites

- Kubernetes cluster running (minikube, kind, or cloud provider)
- `kubectl` configured to connect to your cluster

## Deployment

1. Apply the namespace:
   ```bash
   kubectl apply -f namespace.yaml
   ```

2. Deploy the application:
   ```bash
   kubectl apply -f deployment.yaml
   ```

3. Create the service:
   ```bash
   kubectl apply -f service.yaml
   ```

4. Check the deployment status:
   ```bash
   kubectl get pods -n xd-web-app
   kubectl get svc -n xd-web-app
   ```

## Accessing the Application

The application is exposed via a ClusterIP service. To access it:

1. Port forward to access locally:
   ```bash
   kubectl port-forward -n xd svc/xd-web-app-service 8080:80
   ```
   Then visit http://localhost:8080

2. Or use kubectl proxy:
   ```bash
   kubectl proxy
   ```
   Then visit http://localhost:8001/api/v1/namespaces/xd/services/xd-web-app-service:http/proxy/

## Scaling

To scale the application to more replicas:
```bash
kubectl scale deployment xd-web-app -n xd --replicas=5
```

## Cleanup

To remove all resources:
```bash
kubectl delete namespace xd
```
