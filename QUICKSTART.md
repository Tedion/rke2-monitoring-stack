# Quick Start Guide

## 1. Extract Package
```bash
tar -xzf monitoring-deployment.tar.gz
cd monitoring-deployment
```

## 2. Customize Configuration

Edit `prometheus/values.yaml`:
- **Line 34**: Change cluster name from `"rke2-production"` to your cluster name
- **Lines 177, 221**: Update email addresses for alerts
- **Line 28**: Update storage class if not using `nfs-csi`
- **Lines 463-470**: Update external node exporter IPs (if monitoring external VMs)

## 3. Setup Secrets
```bash
./scripts/setup-secrets.sh
```
Enter:
- SMTP email and password
- Slack webhook URL

## 4. Deploy
```bash
./scripts/install.sh
```

## 5. Access Services

**Get Grafana password:**
```bash
kubectl get secret --namespace monitoring kube-prometheus-stack-grafana -o jsonpath="{.data.admin-password}" | base64 -d
```

**Port-forward:**
```bash
# Grafana (http://localhost:3000)
kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80

# Prometheus (http://localhost:9090)
kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090

# Alertmanager (http://localhost:9093)
kubectl port-forward -n monitoring svc/kube-prometheus-stack-alertmanager 9093:9093
```

## Configuration Checklist

Before deploying, ensure you've updated:

- [ ] Cluster name in `prometheus/values.yaml` (line 34)
- [ ] Email addresses in Alertmanager receivers (lines 177, 221)
- [ ] Storage class name if different from `nfs-csi` (line 28)
- [ ] External node exporter IPs if needed (lines 463-470)
- [ ] Grafana admin password (line 331) - **CHANGE THIS!**
- [ ] SMTP credentials via `setup-secrets.sh`
- [ ] Slack webhook URL via `setup-secrets.sh`

## What Gets Installed

- **Prometheus**: Metrics collection and storage
- **Grafana**: Visualization dashboards
- **Alertmanager**: Alert routing and notifications
- **Loki**: Log aggregation
- **Node Exporter**: Node metrics
- **Kube State Metrics**: Kubernetes metrics
- **Prometheus Pushgateway**: For backup metrics

## Alert Configuration

- ✅ Critical alerts → Email + Slack
- ✅ High alerts → Email + Slack
- ✅ Warning alerts → Slack only
- ✅ Low alerts → Slack only

## Troubleshooting

See `docs/DEPLOYMENT.md` for detailed troubleshooting.

Common issues:
- **PVCs not binding**: Check storage class exists
- **Pods not starting**: Check resource limits and storage
- **Alerts not sending**: Verify secrets are created correctly
