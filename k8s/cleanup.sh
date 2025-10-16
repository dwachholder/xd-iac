#!/bin/bash

# XD Web App Kubernetes Cleanup Script
# This script removes all XD web app resources from the Kubernetes cluster

set -e  # Exit on any error

NAMESPACE="xd"
SERVICE_NAME="xd-web-app-service"
LOCAL_PORT=3000

echo "🧹 Starting XD Web App cleanup..."

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

# Function to check if namespace exists
check_namespace() {
    if ! kubectl get namespace $NAMESPACE &> /dev/null; then
        echo "⚠️  Namespace '$NAMESPACE' does not exist"
        echo "Nothing to clean up"
        exit 0
    fi
    echo "✅ Namespace '$NAMESPACE' found"
}

# Function to show current resources
show_resources() {
    echo "📊 Current resources in namespace '$NAMESPACE':"
    echo ""
    echo "Pods:"
    kubectl get pods -n $NAMESPACE 2>/dev/null || echo "No pods found"
    echo ""
    echo "Services:"
    kubectl get svc -n $NAMESPACE 2>/dev/null || echo "No services found"
    echo ""
    echo "Deployments:"
    kubectl get deployment -n $NAMESPACE 2>/dev/null || echo "No deployments found"
    echo ""
}

# Function to stop port-forwarding processes
stop_port_forwarding() {
    echo "🔌 Checking for running port-forwarding processes..."
    
    # Find processes using the local port
    PORT_PIDS=$(lsof -ti:$LOCAL_PORT 2>/dev/null || true)
    
    if [ -n "$PORT_PIDS" ]; then
        echo "Found port-forwarding processes on port $LOCAL_PORT: $PORT_PIDS"
        echo "Stopping port-forwarding processes..."
        echo $PORT_PIDS | xargs kill -9 2>/dev/null || true
        echo "✅ Port-forwarding processes stopped"
    else
        echo "✅ No port-forwarding processes found on port $LOCAL_PORT"
    fi
}

# Function to delete resources
delete_resources() {
    echo "🗑️  Deleting Kubernetes resources..."
    
    # Delete deployment
    echo "Deleting deployment..."
    kubectl delete deployment xd-web-app -n $NAMESPACE --ignore-not-found=true
    
    # Delete service
    echo "Deleting service..."
    kubectl delete service $SERVICE_NAME -n $NAMESPACE --ignore-not-found=true
    
    # Delete namespace (this will delete all remaining resources in the namespace)
    echo "Deleting namespace..."
    kubectl delete namespace $NAMESPACE --ignore-not-found=true
    
    echo "✅ All resources deleted successfully"
}

# Function to confirm deletion
confirm_deletion() {
    echo ""
    echo "⚠️  WARNING: This will permanently delete all XD web app resources!"
    echo "This includes:"
    echo "  - All pods in namespace '$NAMESPACE'"
    echo "  - All services in namespace '$NAMESPACE'"
    echo "  - All deployments in namespace '$NAMESPACE'"
    echo "  - The entire namespace '$NAMESPACE'"
    echo ""
    
    read -p "Are you sure you want to continue? (yes/no): " -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        echo "❌ Cleanup cancelled by user"
        exit 0
    fi
}

# Function to verify cleanup
verify_cleanup() {
    echo "🔍 Verifying cleanup..."
    
    # Check if namespace still exists
    if kubectl get namespace $NAMESPACE &> /dev/null; then
        echo "⚠️  Namespace '$NAMESPACE' still exists"
        echo "This might indicate that some resources are preventing namespace deletion"
        echo "You may need to manually delete remaining resources"
    else
        echo "✅ Namespace '$NAMESPACE' successfully deleted"
    fi
    
    # Check for any remaining port-forwarding processes
    PORT_PIDS=$(lsof -ti:$LOCAL_PORT 2>/dev/null || true)
    if [ -n "$PORT_PIDS" ]; then
        echo "⚠️  Port-forwarding processes still running on port $LOCAL_PORT: $PORT_PIDS"
        echo "You may need to manually stop them"
    else
        echo "✅ No port-forwarding processes found"
    fi
}

# Main execution
main() {
    echo "=========================================="
    echo "   XD Web App Kubernetes Cleanup"
    echo "=========================================="
    echo ""
    
    # Pre-flight checks
    check_kubectl
    check_cluster
    check_namespace
    
    # Show current resources
    show_resources
    
    # Stop port-forwarding
    stop_port_forwarding
    
    # Confirm deletion
    confirm_deletion
    
    # Delete resources
    delete_resources
    
    # Verify cleanup
    verify_cleanup
    
    echo ""
    echo "🎉 Cleanup completed successfully!"
    echo "All XD web app resources have been removed from the cluster."
}

# Handle script arguments
case "${1:-}" in
    --force|-f)
        echo "🚀 Force mode enabled - skipping confirmation"
        # Pre-flight checks
        check_kubectl
        check_cluster
        check_namespace
        
        # Show current resources
        show_resources
        
        # Stop port-forwarding
        stop_port_forwarding
        
        # Delete resources without confirmation
        delete_resources
        
        # Verify cleanup
        verify_cleanup
        
        echo ""
        echo "🎉 Cleanup completed successfully!"
        ;;
    --help|-h)
        echo "XD Web App Kubernetes Cleanup Script"
        echo ""
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  --force, -f    Skip confirmation prompt and delete immediately"
        echo "  --help, -h     Show this help message"
        echo ""
        echo "This script will remove all XD web app resources from the Kubernetes cluster:"
        echo "  - Deployment: xd-web-app"
        echo "  - Service: xd-web-app-service"
        echo "  - Namespace: xd"
        echo "  - Any running port-forwarding processes on port 3000"
        ;;
    *)
        main "$@"
        ;;
esac
