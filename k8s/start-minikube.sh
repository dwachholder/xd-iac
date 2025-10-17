#!/bin/bash

# Script to start a Kubernetes cluster using minikube
# This script uses minikube to create a local cluster

set -e

echo "🚀 Starting Kubernetes cluster with minikube..."

# Check if minikube is installed
if ! command -v minikube &> /dev/null; then
    echo "📦 Installing minikube..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if command -v brew &> /dev/null; then
            brew install minikube
        else
            echo "❌ Homebrew not found. Please install minikube manually:"
            echo "   curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-amd64"
            echo "   sudo install minikube-darwin-amd64 /usr/local/bin/minikube"
            exit 1
        fi
    else
        # Linux
        curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
        sudo install minikube-linux-amd64 /usr/local/bin/minikube
    fi
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "📦 Installing kubectl..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if command -v brew &> /dev/null; then
            brew install kubectl
        else
            echo "❌ Homebrew not found. Please install kubectl manually."
            exit 1
        fi
    else
        # Linux
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        chmod +x kubectl
        sudo mv kubectl /usr/local/bin/kubectl
    fi
fi

# Start minikube cluster
CLUSTER_NAME="xd-cluster"
echo "🔧 Starting minikube cluster '$CLUSTER_NAME'..."

# Check if cluster is already running
if minikube status --profile="$CLUSTER_NAME" | grep -q "Running"; then
    echo "✅ Cluster '$CLUSTER_NAME' is already running"
else
    # Start minikube with specific configuration
    minikube start --profile="$CLUSTER_NAME" \
        --memory=4096 \
        --cpus=2 \
        --disk-size=20g \
        --driver=docker \
        --ports=80:80 \
        --ports=443:443
fi

# Set kubectl context
echo "🔗 Setting kubectl context..."
minikube kubectl --profile="$CLUSTER_NAME" -- cluster-info

# Wait for cluster to be ready
echo "⏳ Waiting for cluster to be ready..."
minikube kubectl --profile="$CLUSTER_NAME" -- wait --for=condition=Ready nodes --all --timeout=300s

# Show cluster info
echo "✅ Kubernetes cluster is ready!"
echo ""
echo "📊 Cluster Information:"
minikube kubectl --profile="$CLUSTER_NAME" -- cluster-info
echo ""
echo "🔧 Available nodes:"
minikube kubectl --profile="$CLUSTER_NAME" -- get nodes
echo ""
echo "📝 To use this cluster:"
echo "   minikube kubectl --profile=$CLUSTER_NAME -- get pods --all-namespaces"
echo "   # Or set kubectl context:"
echo "   kubectl config use-context $CLUSTER_NAME"
echo ""
echo "🌐 To access services:"
echo "   minikube service <service-name> --profile=$CLUSTER_NAME"
echo ""
echo "🛑 To stop the cluster:"
echo "   minikube stop --profile=$CLUSTER_NAME"
echo ""
echo "🗑️  To delete the cluster:"
echo "   minikube delete --profile=$CLUSTER_NAME"
