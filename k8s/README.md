# XD Web App Kubernetes Setup

This repository contains Kubernetes manifests to deploy the `dwachholder/xd-web-app:main-8cae1a6` Docker image with 2 replicas.

## Files

- `namespace.yaml` - Creates a dedicated namespace for the application
- `deployment.yaml` - Deploys the application with 2 replicas
- `service.yaml` - Exposes the application within the cluster (ClusterIP)
- `loadbalancer.yaml` - Provides external access with load balancing (LoadBalancer)

## Prerequisites

- Kubernetes cluster running (minikube, kind, or cloud provider)
- `kubectl` configured to connect to your cluster

### Starting a Local Cluster with Minikube

To start a local Kubernetes cluster using minikube:

```bash
./start-k8s.sh
```

This script will:

- Install minikube if not already installed
- Install kubectl if not already installed
- Start a minikube cluster with appropriate configuration
- Set up port forwarding for HTTP (80) and HTTPS (443)
- Configure kubectl to use the new cluster

## Deployment

### Automated Deployment (Recommended)

Use the provided deployment script for a complete setup:

```bash
./deploy.sh
```

This script will:

- Deploy all Kubernetes resources
- Wait for the deployment to be ready
- Wait for LoadBalancer external IP assignment
- Show deployment status
- Set up port-forwarding for local access

### Manual Deployment

Deploy resources individually:

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

4. Create the load balancer:

   ```bash
   kubectl apply -f loadbalancer.yaml
   ```

5. Check the deployment status:
   ```bash
   kubectl get pods -n xd
   kubectl get svc -n xd
   ```

## Accessing the Application

The application is exposed via both ClusterIP and LoadBalancer services:

### External Access (LoadBalancer)

The LoadBalancer service provides external access with automatic load balancing:

1. Check the external IP:

   ```bash
   kubectl get svc xd-web-app-loadbalancer -n xd
   ```

2. Access the application via the external IP:
   ```bash
   # If external IP is assigned (e.g., 203.0.113.1)
   curl http://203.0.113.1
   # Or open in browser: http://203.0.113.1
   ```

**Note**: External IP assignment depends on your cluster environment:

- **Cloud providers** (AWS, GCP, Azure): External IP assigned automatically
- **Local clusters** (minikube, kind): May show `<pending>` status

### Minikube Service Access

With minikube, you can easily access services using:

```bash
# Access the service directly
minikube service xd-web-app-service --profile=xd-cluster -n xd

# Or get the service URL
minikube service xd-web-app-service --profile=xd-cluster -n xd --url
```

### Internal Access (ClusterIP)

For internal cluster access or local development:

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
