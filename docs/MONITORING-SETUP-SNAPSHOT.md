# Monitoring Namespace – Current Setup Snapshot

**Cluster:** RKE2  
**Namespace:** `monitoring`  
**Date captured:** 2026-02-18

---

## 1. Overview

| Component | Purpose | Status |
|-----------|---------|--------|
| **Prometheus** | Collects metrics from the cluster and backup jobs | Running (1 replica) |
| **Alertmanager** | Sends alerts by email and Slack when something goes wrong | Running (1 replica) |
| **Grafana** | Web dashboards to view metrics and graphs | Running (3/3 containers) |
| **Pushgateway** | Receives backup job metrics from backup scripts | Running |
| **Loki** | Log aggregation | Running (2 replicas + caches) |
| **Promtail** | Sends log data to Loki | Running (DaemonSet on all nodes) |
| **Tempo** | Distributed tracing | Running (ingesters, querier, compactor) |
| **Node exporter** | Server (CPU, disk, memory) metrics per node | Running (3 nodes) |
| **Postgres exporters** | Database metrics (ODK, Social Registry) | Running |
| **Blackbox exporter** | HTTP/connectivity checks | Running |

---

## 2. Access (NodePorts)

Use **http://\<cluster-node-ip\>:\<port\>** (replace with your node IP).

| Tool | Port | URL pattern |
|------|------|-------------|
| **Grafana** (dashboards) | 30180 | `http://<node-ip>:30180` |
| **Prometheus** (metrics UI) | 30090 | `http://<node-ip>:30090` |
| **Alertmanager** (alerts UI) | 30093 | `http://<node-ip>:30093` |
| **Loki** | 30100 | `http://<node-ip>:30100` |
| **Pushgateway** | 32214 | Internal use by backup scripts |

---

## 3. Alert Rules (PrometheusRules)

- **backup-alerts** – Backup failed, backup not run, NFS mount failed  
- **application-alerts**, **database-alerts**, **infrastructure-alerts**  
- **kubernetes-alerts**, **openg2p-services-alerts**, **prod-database-alerts**  
- Plus built-in kube-prometheus-stack rules

---

## 4. Notifications

- **Email:** Gmail – critical/high alerts and “resolved” notifications  
- **Slack:** #alerts – same  
- **Backup:** Failure and “backup not run” trigger alerts; success triggers “resolved” email

---

## 5. Backup Monitoring Flow

1. Backup scripts push metrics to Pushgateway  
2. Prometheus scrapes and evaluates backup-alerts  
3. Alertmanager sends email + Slack on failure; “resolved” when next run succeeds  
4. Grafana dashboard “Backup metrics” shows status, duration, last success

---

## 6. Key Repo Paths

- `monitoring/prometheus/values.yaml` – Helm values  
- `monitoring/prometheus/alert-rules/*.yaml` – Alert rules (e.g. backup-alerts)
