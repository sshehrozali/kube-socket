#!/usr/bin/env bash
# Provisions a local kind cluster and demo workloads for KubeTracer development.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
KIND_MANIFESTS="${REPO_ROOT}/deploy/kind"

cd "${REPO_ROOT}"

echo "=========================================="
echo "Setting up Network Listener Demo"
echo "=========================================="
echo ""

echo "Step 1: Creating kind cluster with port mappings..."
if kind get clusters | grep -q "^kind$"; then
    echo "Cluster 'kind' already exists. Deleting..."
    kind delete cluster
fi
kind create cluster --config "${KIND_MANIFESTS}/kind-config.yaml"
echo "✓ Cluster created"
echo ""

echo "Step 2: Building Docker image (kubetracer:v3)..."
docker build -t kubetracer:v3 .
echo "✓ Image built"
echo ""

echo "Step 3: Loading image into kind cluster..."
kind load docker-image kubetracer:v3
echo "✓ Image loaded"
echo ""

echo "Step 4: Deploying nginx..."
kubectl apply -f "${KIND_MANIFESTS}/nginx-deployment.yaml"
echo "✓ Nginx deployed"
echo ""

echo "Step 5: Deploying Spring app..."
kubectl apply -f "${KIND_MANIFESTS}/spring-app.yaml"
echo "✓ Spring app deployed"
echo ""

echo "Step 6: Deploying kubetracer DaemonSet..."
kubectl apply -f "${KIND_MANIFESTS}/daemonset.yaml"
echo "✓ Packet sniffer deployed"
echo ""

echo "Step 7: Deploying curl pod for testing..."
kubectl apply -f "${KIND_MANIFESTS}/curl-deployment.yaml"
echo "✓ Curl pod deployed"
echo ""

echo "Step 8: Waiting for all pods to be ready..."
kubectl wait --for=condition=ready pod -l app=my-nginx --timeout=60s
kubectl wait --for=condition=ready pod -l app=spring-app --timeout=60s
kubectl wait --for=condition=ready pod -l name=kubetracer --timeout=60s
kubectl wait --for=condition=ready pod -l app=curl --timeout=60s
echo "✓ All pods ready"
echo ""

echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "Test external traffic:"
echo "  Nginx:  curl http://localhost:32407"
echo "  Spring: curl http://localhost:30000"
echo ""
echo "Test pod-to-pod traffic:"
echo "  kubectl exec -l app=curl -- curl -s http://10.244.1.2"
echo "  kubectl exec -l app=curl -- curl -s http://spring-app.default.svc.cluster.local:3000"
echo ""
echo "View kubetracer logs:"
echo "  kubectl logs -l name=kubetracer --follow"
echo ""
echo "View all pods:"
echo "  kubectl get pods -o wide"
echo ""
