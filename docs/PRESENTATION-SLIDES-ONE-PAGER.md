# Monitoring & Alerts – One-Page Summary (for presentations)

---

**Slide 1 – Title**  
**Monitoring & Alerts: How We Watch the System and Stay Informed**

---

**Slide 2 – What is it?**  
Monitoring = tools that **check 24/7** that servers, databases, backups, and apps are healthy.  
When something goes wrong → we get **email + Slack** so we can act quickly.

---

**Slide 3 – What you get**  
- **Early warning** – We hear about problems before users do.  
- **One place to look** – Dashboards show status of servers, DBs, backups.  
- **Automatic alerts** – Email and Slack tell us *what* failed and *where*.  
- **“Resolved” messages** – When the issue is fixed (e.g. backup runs again), we get a confirmation.

---

**Slide 4 – How we get notified**  
- **Email** – Critical and important alerts (e.g. backup failed, database down).  
- **Slack (#alerts)** – Same alerts in one channel for the team.  
- **Resolved** – Message when the problem is fixed; no extra spam.

---

**Slide 5 – What we monitor**  
Servers • Databases • **Backups** • Key applications • Logs

---

**Slide 6 – Where to see status**  
**Grafana dashboards:** `http://<server-ip>:30180`  
Shows system health and **backup status** (last run, success/failure).  
*(IT can provide the exact link and login.)*

---

**Slide 7 – What to do when you get an alert**  
1. Read the subject/title (e.g. “Backup failed”).  
2. Check Slack #alerts for details.  
3. Notify the technical team if you’re not fixing it.  
4. “Resolved” = issue fixed; no action needed.

---

**Slide 8 – Takeaway**  
**We use monitoring to watch our systems 24/7 and get email and Slack when something goes wrong—and when it’s fixed—so the team can react quickly.**

---

*Full narrative: PRESENTATION-MONITORING-FOR-NON-TECHNICAL.md*
