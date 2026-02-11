# Detailed Deployment Guide

## Pre-Deployment Checklist

- [ ] RKE2 cluster is running and accessible
- [ ] kubectl is configured and can access the cluster
- [ ] Helm 3.x is installed
- [ ] Storage class `nfs-csi` exists (or update values.yaml)
- [ ] SMTP credentials ready (Gmail App Password recommended)
- [ ] Slack webhook URL ready
- [ ] Sufficient cluster resources available

## Step-by-Step Deployment

### 1. Prepare the Deployment Package

```bash
# Copy the deployment package to your target machine
scp -r monitoring-deployment/ user@target-cluster:/path/to/

# Or clone/extract from your source control
```

### 2. Customize Configuration

#### Update Prometheus Values (`prometheus/values.yaml`)

**Required Changes:**
- Line 34: Update `cluster: "rke2-production"` to your cluster name
- Line 92-94: Update SMTP configuration (or keep defaults if using Gmail)
- Lines 163, 177, 221: Update email addresses in receivers
- Lines 463-470: Update external node exporter IPs if monitoring external VMs
- Line 28: Update `storageClassName` if not using `nfs-csi`

**Optional Changes:**
- Adjust resource limits (CPU/memory)
- Modify retention periods
- Change scrape intervals
- Update Grafana admin password (line 331)

#### Update Loki Values (`loki/values.yaml`)

- Adjust storage size (line 6)
- Modify retention period (line 27)

### 3. Create Secrets

```bash
cd monitoring-deployment
./scripts/setup-secrets.sh
```

This will prompt for:
- SMTP email and password
- SMTP server (defaults to Gmail)
- Slack webhook URL

### 4. Deploy Monitoring Stack

```bash
./scripts/install.sh
```

The script will:
1. Add Helm repositories
2. Create monitoring namespace
3. Install Prometheus Pushgateway
4. Install Prometheus Stack
5. Install Loki Stack
6. Apply alert rules
7. Wait for pods to be ready

### 5. Verify Installation

```bash
# Check all pods are running
kubectl get pods -n monitoring

# Check services
kubectl get svc -n monitoring

# Check alert rules
kubectl get prometheusrules -n monitoring
```

### 6. Access Services

**Grafana:**
```bash
# Get admin password
kubectl get secret --namespace monitoring kube-prometheus-stack-grafana -o jsonpath="{.data.admin-password}" | base64 -d

# Port-forward
kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80
# Access at http://localhost:3000 (admin / <password>)
```

**Prometheus:**
```bash
kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090
# Access at http://localhost:9090
```

**Alertmanager:**
```bash
kubectl port-forward -n monitoring svc/kube-prometheus-stack-alertmanager 9093:9093
# Access at http://localhost:9093
```

## Alert Rules

The deployment includes three sets of alert rules:

1. **kubernetes-alerts.yaml**: Kubernetes-specific alerts
   - Pod failures, crashes, not ready
   - Node not ready, memory/disk pressure
   - High CPU/memory usage

2. **infrastructure-alerts.yaml**: Infrastructure alerts
   - High/Critical CPU usage
   - High/Critical memory usage
   - Low/Critical disk space

3. **backup-alerts.yaml**: Backup-related alerts
   - Backup failures
   - Backup not run
   - NFS mount failures

## Alert Routing

- **Critical**: Email + Slack (immediate, repeat every 1h)
- **High**: Email + Slack (30s wait, repeat every 6h)
- **Warning**: Slack only (1m wait, repeat every 12h)
- **Low**: Slack only (5m wait, repeat every 24h)

## Troubleshooting

### Pods Not Starting

```bash
# Check pod logs
kubectl logs -n monitoring <pod-name>

# Check pod events
kubectl describe pod -n monitoring <pod-name>

# Check PVC status
kubectl get pvc -n monitoring
```

### Alertmanager Not Sending Emails

1. Verify secrets exist:
   ```bash
   kubectl get secrets -n monitoring | grep alertmanager
   ```

2. Check Alertmanager config:
   ```bash
   kubectl get secret alertmanager-kube-prometheus-stack-alertmanager -n monitoring -o jsonpath='{.data.alertmanager\.yaml}' | base64 -d
   ```

3. Check Alertmanager logs:
   ```bash
   kubectl logs -n monitoring -l app.kubernetes.io/name=alertmanager
   ```

### Prometheus Not Scraping

1. Check ServiceMonitors:
   ```bash
   kubectl get servicemonitors -A
   ```

2. Check Prometheus targets:
   - Access Prometheus UI
   - Go to Status > Targets
   - Check for errors

### Storage Issues

If PVCs are not binding:
1. Verify storage class exists: `kubectl get storageclass`
2. Check PVC status: `kubectl get pvc -n monitoring`
3. Update `storageClassName` in values.yaml if needed

## Upgrading

```bash
# Update Helm repos
helm repo update

# Upgrade Prometheus Stack
helm upgrade kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  -n monitoring \
  -f prometheus/values.yaml

# Upgrade Loki Stack
helm upgrade loki-stack grafana/loki-stack \
  -n monitoring \
  -f loki/values.yaml
```

## Uninstalling

```bash
# Delete alert rules
kubectl delete -f prometheus/alert-rules/

# Uninstall Helm releases
helm uninstall kube-prometheus-stack -n monitoring
helm uninstall loki-stack -n monitoring
helm uninstall prometheus-pushgateway -n monitoring

# Delete namespace (this will delete all resources)
kubectl delete namespace monitoring
```

## External Node Exporters

If you need to monitor external VMs, update the `external-node-exporters` job in `prometheus/values.yaml` (lines 460-475) with the correct IP addresses and ports.

Make sure Node Exporter is installed and running on those VMs:
```bash
# On each VM
wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz
tar xvfz node_exporter-1.6.1.linux-amd64.tar.gz
sudo cp node_exporter-1.6.1.linux-amd64/node_exporter /usr/local/bin/
sudo systemctl enable node_exporter
sudo systemctl start node_exporter
```

## Security Notes

1. Change Grafana admin password immediately after deployment
2. Use Gmail App Passwords (not regular passwords) for SMTP
3. Consider using OAuth2 for SMTP if available
4. Restrict access to monitoring namespace using RBAC
5. Use TLS/HTTPS for production deployments
