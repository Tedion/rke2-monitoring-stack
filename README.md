# Monitoring Stack Deployment Package for RKE2

This package contains everything needed to deploy a complete monitoring stack (Prometheus, Grafana, Alertmanager, Loki) on an RKE2 cluster.

## Contents

- `prometheus/values.yaml` - Prometheus Stack Helm values
- `prometheus/alert-rules/` - Prometheus alert rules
- `loki/values.yaml` - Loki Stack Helm values
- `scripts/install.sh` - Installation script
- `scripts/setup-secrets.sh` - Secret setup script
- `docs/DEPLOYMENT.md` - Detailed deployment instructions

## Prerequisites

1. RKE2 cluster running and accessible via kubectl
2. Helm 3.x installed
3. kubectl configured to access the target cluster
4. Storage class available (default: `nfs-csi`)
5. SMTP credentials for email alerts
6. Slack webhook URL for Slack notifications

## Quick Start

1. **Setup Secrets** (Required before installation):
   ```bash
   ./scripts/setup-secrets.sh
   ```

2. **Customize Configuration**:
   - Edit `prometheus/values.yaml`:
     - Update `cluster` name in `externalLabels` (line 34)
     - Update email addresses in Alertmanager receivers
     - Update storage class if different from `nfs-csi`
     - Update external node exporter IPs if needed (lines 463-470)
   
   - Edit `loki/values.yaml` if needed:
     - Adjust storage size
     - Modify retention period

3. **Deploy**:
   ```bash
   ./scripts/install.sh
   ```

## Configuration Details

### Alert Routing
- **Critical alerts**: Email + Slack
- **High alerts**: Email + Slack  
- **Warning alerts**: Slack only
- **Low alerts**: Slack only

### Storage Requirements
- Prometheus: 200Gi
- Grafana: 20Gi
- Alertmanager: 10Gi
- Loki: 100Gi

### Resource Limits
- Prometheus: 4 CPU, 8Gi memory
- Grafana: 1 CPU, 1Gi memory
- Alertmanager: 0.5 CPU, 512Mi memory (per replica, 2 replicas)

## Post-Installation

1. Get Grafana admin password:
   ```bash
   kubectl get secret --namespace monitoring kube-prometheus-stack-grafana -o jsonpath="{.data.admin-password}" | base64 -d
   ```

2. Port-forward to access services:
   ```bash
   # Grafana
   kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80
   
   # Prometheus
   kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090
   
   # Alertmanager
   kubectl port-forward -n monitoring svc/kube-prometheus-stack-alertmanager 9093:9093
   ```

## Troubleshooting

See `docs/DEPLOYMENT.md` for detailed troubleshooting steps.
