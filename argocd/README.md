# Minimal ArgoCD Configuration

This directory contains a minimal ArgoCD setup that watches a GitHub repository and automatically updates the xd-web-app pod when changes are detected.

## 📁 Directory Structure

```
argocd/
├── applications/           # ArgoCD Application definition
│   └── xd-web-app.yaml   # Application that watches GitHub repo
└── README.md             # This file
```

## 🚀 Quick Start

### Prerequisites

- Kubernetes cluster running
- ArgoCD installed in your cluster
- `kubectl` configured to connect to your cluster

### 1. Install ArgoCD (if not already installed)

```bash
# Create ArgoCD namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
```

### 2. Get ArgoCD Admin Password

```bash
# Get the initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### 3. Access ArgoCD UI

```bash
# Port forward to access ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Access ArgoCD at: https://localhost:8080
# Username: admin
# Password: [password from step 2]
```

### 4. Deploy the XD Web App

```bash
# Apply the application
kubectl apply -f argocd/applications/xd-web-app.yaml
```

## 🔄 How It Works

1. **Git Watch**: ArgoCD monitors the GitHub repository (`https://github.com/dwachholder/xd-iac`) for changes
2. **Auto Sync**: When changes are detected in the `k8s/` directory, ArgoCD automatically syncs the changes
3. **Pod Update**: The xd-web-app pod gets updated with the new configuration from the repository

## 📋 Configuration

### Update Repository URL

If you're using a different repository, update the `repoURL` in `applications/xd-web-app.yaml`:

```yaml
source:
  repoURL: https://github.com/your-username/your-repo
  targetRevision: HEAD
  path: k8s
```

## 🎯 Usage

### Deploying Changes

Simply commit and push changes to your GitHub repository:

```bash
# Make changes to your k8s/ directory
git add k8s/
git commit -m "Update xd-web-app configuration"
git push origin main

# ArgoCD will automatically detect and sync the changes
```

### Manual Sync (if needed)

```bash
# Sync application manually
argocd app sync xd-web-app

# Check application status
argocd app get xd-web-app
```

### Monitoring

```bash
# Check application status
kubectl get applications -n argocd

# View application events
kubectl describe application xd-web-app -n argocd

# Check pod status
kubectl get pods -n xd
```

## 🔍 Troubleshooting

### Common Issues

1. **Application Stuck in "Progressing" State**:
   ```bash
   # Check application events
   kubectl describe application xd-web-app -n argocd
   
   # Check pod status
   kubectl get pods -n xd
   ```

2. **Sync Failures**:
   ```bash
   # Force sync
   argocd app sync xd-web-app --force
   ```

3. **Permission Denied**:
   ```bash
   # Check if ArgoCD can access the repository
   argocd repo list
   ```

## 📚 Additional Resources

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [GitOps Principles](https://www.gitops.tech/)

---

**Note**: This is a minimal setup. For production use, consider adding RBAC, projects, and other security configurations as needed.