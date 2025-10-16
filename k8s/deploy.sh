#!/bin/bash

# XD Web App Kubernetes Deployment Script
# This script deploys the XD web app to Kubernetes and sets up port-forwarding

set -e  # Exit on any error

NAMESPACE="xd"
SERVICE_NAME="xd-web-app-service"
LOCAL_PORT=8080
SERVICE_PORT=80

echo "🚀 Starting XD Web App deployment..."

# Function to check if kubectl is available
check_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        echo "❌ kubectl is not installed or not in PATH"
        exit 1
    fi
    echo "✅ kubectl is available"
}

# Function to check if cluster is accessible
check_cluster() {
    if ! kubectl cluster-info &> /dev/null; then
        echo "❌ Cannot connect to Kubernetes cluster"
        echo "Please ensure your cluster is running and kubectl is configured"
        exit 1
    fi
    echo "✅ Connected to Kubernetes cluster"
}

# Function to apply Kubernetes manifests
deploy_resources() {
    echo "📦 Applying Kubernetes manifests..."
    
    # Apply namespace
    echo "Creating namespace..."
    kubectl apply -f namespace.yaml
    
    # Apply deployment
    echo "Deploying application..."
    kubectl apply -f deployment.yaml
    
    # Apply service
    echo "Creating service..."
    kubectl apply -f service.yaml
    
    echo "✅ All resources applied successfully"
}

# Function to wait for deployment to be ready
wait_for_deployment() {
    echo "⏳ Waiting for deployment to be ready..."
    kubectl wait --for=condition=available --timeout=300s deployment/xd-web-app -n $NAMESPACE
    echo "✅ Deployment is ready"
}

# Function to show deployment status
show_status() {
    echo "📊 Deployment Status:"
    echo "Pods:"
    kubectl get pods -n $NAMESPACE
    echo ""
    echo "Services:"
    kubectl get svc -n $NAMESPACE
    echo ""
    echo "Deployment:"
    kubectl get deployment -n $NAMESPACE
}

# Function to setup port-forwarding
setup_port_forward() {
    echo "🔗 Setting up port-forwarding..."
    echo "The application will be available at: http://localhost:$LOCAL_PORT"
    echo "Press Ctrl+C to stop port-forwarding"
    echo ""
    
    # Start port-forwarding in background
    kubectl port-forward -n $NAMESPACE svc/$SERVICE_NAME $LOCAL_PORT:$SERVICE_PORT &
    PORT_FORWARD_PID=$!
    
    # Wait a moment for port-forward to establish
    sleep 2
    
    # Check if port-forward is working
    if kill -0 $PORT_FORWARD_PID 2>/dev/null; then
        echo "✅ Port-forwarding is active (PID: $PORT_FORWARD_PID)"
        echo "🌐 Open your browser and go to: http://localhost:$LOCAL_PORT"
        echo ""
        echo "To stop port-forwarding, run: kill $PORT_FORWARD_PID"
        echo "Or press Ctrl+C in this terminal"
        
        # Wait for user interrupt
        trap "echo ''; echo '🛑 Stopping port-forwarding...'; kill $PORT_FORWARD_PID 2>/dev/null; exit 0" INT
        wait $PORT_FORWARD_PID
    else
        echo "❌ Failed to start port-forwarding"
        exit 1
    fi
}

# Main execution
main() {
    echo "=========================================="
    echo "   XD Web App Kubernetes Deployment"
    echo "=========================================="
    echo ""
    
    # Pre-flight checks
    check_kubectl
    check_cluster
    
    # Deploy resources
    deploy_resources
    
    # Wait for deployment
    wait_for_deployment
    
    # Show status
    show_status
    
    # Setup port-forwarding
    setup_port_forward
}

# Run main function
main "$@"
