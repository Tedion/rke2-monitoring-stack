#!/bin/bash
# Installation script for monitoring stack (LGTM: Loki, Grafana, Tempo, Mimir/Prometheus)
# Updated: Added blackbox exporter and full LGTM stack support

set -e

echo "=========================================="
echo "Installing Monitoring Stack (LGTM)"
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
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
helm repo update

# Create monitoring namespace
echo "Creating monitoring namespace..."
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# Install Prometheus Pushgateway (for backup metrics)
echo "Installing Prometheus Pushgateway..."
helm upgrade --install prometheus-pushgateway prometheus-community/prometheus-pushgateway \
  --namespace monitoring \
  --set serviceMonitor.enabled=true

# Install Prometheus Blackbox Exporter (for HTTP/TCP probes - symptom-based monitoring)
echo "Installing Prometheus Blackbox Exporter..."
helm upgrade --install prometheus-blackbox-exporter prometheus-community/prometheus-blackbox-exporter \
  --namespace monitoring \
  --set serviceMonitor.enabled=true

# Install Grafana Tempo (distributed tracing)
# Note: Tempo chart may be deprecated - install with timeout handling
echo "Installing Grafana Tempo..."
if [ -f "tempo/values.yaml" ]; then
    # Try tempo-distributed chart first (recommended), fallback to tempo
    if helm search repo grafana/tempo-distributed &>/dev/null; then
        echo "Using tempo-distributed chart..."
        helm upgrade --install tempo grafana/tempo-distributed \
          --namespace monitoring \
          -f tempo/values.yaml \
          --wait --timeout 10m || echo "Warning: Tempo installation failed or timed out - continuing..."
    else
        echo "Using tempo chart (may be deprecated)..."
        helm upgrade --install tempo grafana/tempo \
          --namespace monitoring \
          -f tempo/values.yaml \
          --wait --timeout 10m || echo "Warning: Tempo installation failed or timed out - continuing..."
    fi
else
    echo "Warning: tempo/values.yaml not found, skipping Tempo installation"
fi

# Install OpenTelemetry Collector (unified observability data collection)
echo "Installing OpenTelemetry Collector..."
if [ -f "otel-collector/values.yaml" ]; then
    # Install without --wait to avoid timeout - pods will start in background
    # The collector is optional for core monitoring functionality
    helm upgrade --install otel-collector open-telemetry/opentelemetry-collector \
      --namespace monitoring \
      -f otel-collector/values.yaml \
      --timeout 5m || echo "Warning: OpenTelemetry Collector installation had issues - continuing with core stack..."
    echo "OpenTelemetry Collector installation initiated (check status with: kubectl get pods -n monitoring -l app.kubernetes.io/name=opentelemetry-collector)"
else
    echo "Warning: otel-collector/values.yaml not found, skipping OTel Collector installation"
fi

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
echo "Access Tempo (if installed):"
echo "  kubectl port-forward -n monitoring svc/tempo 3200:3200"
echo ""
echo "=========================================="
echo "Next Steps:"
echo "=========================================="
echo "1. Configure blackbox HTTP targets in prometheus/values.yaml"
echo "2. Install postgres_exporter on DB VM (172.16.16.229) if not already installed"
echo "3. Create etcd client cert secret for etcd metrics:"
echo "   kubectl create secret generic etcd-client-cert -n monitoring \\"
echo "     --from-file=ca.crt=/var/lib/rancher/rke2/server/tls/etcd/server-ca.crt \\"
echo "     --from-file=tls.crt=/var/lib/rancher/rke2/server/tls/etcd/server-client.crt \\"
echo "     --from-file=tls.key=/var/lib/rancher/rke2/server/tls/etcd/server-client.key"
echo "4. Uncomment prometheus.prometheusSpec.secrets in values.yaml after creating etcd secret"
echo ""
