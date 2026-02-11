#!/bin/bash
# Installation script for monitoring stack

set -e

echo "=========================================="
echo "Installing Monitoring Stack"
echo "=========================================="

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "Error: kubectl is not installed"
    exit 1
fi

# Check if helm is available
if ! command -v helm &> /dev/null; then
    echo "Error: helm is not installed"
    exit 1
fi

# Add Helm repos
echo "Adding Helm repositories..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Create monitoring namespace
echo "Creating monitoring namespace..."
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# Install Prometheus Pushgateway (for backup metrics)
echo "Installing Prometheus Pushgateway..."
helm upgrade --install prometheus-pushgateway prometheus-community/prometheus-pushgateway \
  --namespace monitoring \
  --set serviceMonitor.enabled=true

# Install Prometheus Stack
echo "Installing Prometheus Stack..."
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  -f prometheus/values.yaml \
  --wait --timeout 10m

# Install Loki Stack
echo "Installing Loki Stack..."
helm upgrade --install loki-stack grafana/loki-stack \
  --namespace monitoring \
  -f loki/values.yaml \
  --wait --timeout 10m

# Apply Alert Rules
echo "Applying Prometheus alert rules..."
kubectl apply -f prometheus/alert-rules/

# Apply Service Monitors (if any)
if [ -d "prometheus/servicemonitors" ] && [ "$(ls -A prometheus/servicemonitors)" ]; then
    echo "Applying Service Monitors..."
    kubectl apply -f prometheus/servicemonitors/
fi

# Wait for pods to be ready
echo "Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=grafana -n monitoring --timeout=5m || true
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=prometheus -n monitoring --timeout=5m || true

echo ""
echo "=========================================="
echo "Installation Complete!"
echo "=========================================="
echo ""
echo "Access Grafana:"
echo "  kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80"
echo "  Default username: admin"
echo "  Default password: changeme (change in values.yaml)"
echo ""
echo "Access Prometheus:"
echo "  kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090"
echo ""
echo "Access Alertmanager:"
echo "  kubectl port-forward -n monitoring svc/kube-prometheus-stack-alertmanager 9093:9093"
echo ""
