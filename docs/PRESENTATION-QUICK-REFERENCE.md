# Quick Reference Card – Monitoring & Alerts

**Print this page for easy reference during your presentation**

---

## 🎯 Key Points (30-second elevator pitch)

**"We have a 24/7 monitoring system that watches our servers, databases, and backups. When something goes wrong, it automatically sends email and Slack alerts so we can fix problems before users notice. Especially important: backup monitoring ensures our data is protected."**

---

## 📧 Alert Channels

- **Email:** [Your Team Email]
- **Slack:** `#alerts` channel
- **Dashboards:** `http://[server-ip]:30180` (Grafana)

---

## 🚨 Alert Priority Levels

| Level | Email? | Slack? | What It Means |
|-------|--------|--------|---------------|
| **Critical** | ✅ | ✅ | Immediate action needed (e.g., backup failed) |
| **High** | ✅ | ✅ | Important, needs attention soon |
| **Warning** | ❌ | ✅ | Monitor, less urgent |
| **Low** | ❌ | ✅ | Informational only |

---

## 💾 Backup Monitoring (Critical!)

**What we monitor:**
- ✅ Backup success/failure
- ⏰ Last backup time
- ⏱️ Backup duration
- 📁 Storage availability

**Alerts you'll get:**
- **BackupFailed** → Backup job failed → Fix immediately
- **BackupNotRun** → Backup hasn't run in 24h → Investigate
- **NFSMountFailed** → Backup storage unavailable → Critical!
- **Resolved** → Backup succeeded → No action needed

---

## ✅ What to Do When You Get an Alert

1. **Read the subject/title** → Tells you what's wrong
2. **Check Slack #alerts** → Team discussion
3. **Forward to technical team** → If you're not fixing it
4. **"Resolved" = Fixed** → No action needed

---

## 📊 Dashboard Access

- **Grafana:** `http://[server-ip]:30180` (main dashboards)
- **Prometheus:** `http://[server-ip]:30090` (metrics)
- **Alertmanager:** `http://[server-ip]:30093` (alerts UI)

*Contact IT for login credentials*

---

## 🎯 Benefits Summary

✅ Faster problem detection (minutes, not hours)  
✅ Proactive management (fix before escalation)  
✅ Backup protection (data safety)  
✅ Team coordination (Slack #alerts)  
✅ Visibility (dashboards show everything)  

---

## ❓ Common Questions

**Q: Will I get spammed?**  
A: No. Only real issues trigger alerts.

**Q: What if I'm not technical?**  
A: Forward alerts to technical team or post in Slack.

**Q: How often do backups run?**  
A: Daily. You'll only get an alert if one fails.

**Q: Can I see dashboards?**  
A: Yes! Ask IT for access. No technical knowledge needed.

---

*Keep this card handy during your presentation!*
