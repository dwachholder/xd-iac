#!/bin/bash

echo "🚀 Starting XD Infrastructure Setup..."

# Run ArgoCD setup script
echo "📦 Setting up ArgoCD..."
bash argocd/run.sh

# Wait a moment for ArgoCD to be fully ready
echo "⏳ Waiting for ArgoCD to be ready..."
sleep 5

# Start port forwarding for xd-web-app-service in background
echo "🌐 Starting port forwarding for xd-web-app-service (port 3000)..."
kubectl port-forward -n xd svc/xd-web-app-service 3000:80 &
PORT_FORWARD_PID1=$!

# Start port forwarding for ArgoCD server in background
echo "🔧 Starting port forwarding for ArgoCD server (port 8080)..."
kubectl port-forward svc/argocd-server -n argocd 8080:443 &
PORT_FORWARD_PID2=$!

# Store the PIDs so we can kill them later if needed
echo $PORT_FORWARD_PID1 > .port-forward.pid
echo $PORT_FORWARD_PID2 >> .port-forward.pid

echo "✅ Setup complete!"
echo "📊 ArgoCD UI: http://localhost:8080"
echo "🌐 XD Web App: http://localhost:3000"
echo ""
echo "To stop port forwarding, run: kill \$(cat .port-forward.pid)"
echo "Or press Ctrl+C to stop this script"

# Keep the script running and wait for user interrupt
trap 'echo "🛑 Stopping port forwarding..."; kill $PORT_FORWARD_PID1 $PORT_FORWARD_PID2 2>/dev/null; rm -f .port-forward.pid; exit 0' INT

# Wait for the port forward processes
wait $PORT_FORWARD_PID1 $PORT_FORWARD_PID2
