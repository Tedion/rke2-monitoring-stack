# Monitoring & Alerts – Overview for Non-Technical Staff

**Purpose:** Short, simple overview of how we watch the system and get notified when something needs attention.

---

## What is “monitoring”?

We run a set of tools that **continuously check** that servers, databases, backups, and applications are healthy.  
When something goes wrong or is about to go wrong, the system **notifies the right people** by email and Slack so we can act quickly.

Think of it as a **24/7 watchman** that only speaks up when attention is needed.

---

## What do we get from it?

| Benefit | In plain language |
|--------|--------------------|
| **Early warning** | We find out about problems (e.g. backup failed, database down) quickly, instead of users noticing first. |
| **One place to look** | Dashboards show the status of important systems (servers, databases, backups) in graphs and numbers. |
| **Automatic alerts** | Email and Slack messages tell us *what* went wrong and *where*, so we know what to fix. |
| **Recovery confirmation** | When we fix an issue (e.g. backup runs again successfully), we get a “resolved” message so we know it’s OK. |

---

## How do we get notified?

- **Email** – Critical and important alerts are sent to the team’s email (e.g. backup failures, database issues).  
- **Slack** – The same alerts appear in the **#alerts** channel so the team can see and discuss them.  
- **Resolved alerts** – When a problem is fixed (e.g. backup runs successfully again), we get an email/Slack saying the alert is “resolved.”

We do **not** get spammed: only real issues and their resolution are reported.

---

## What do we monitor?

- **Servers** – CPU, memory, disk, basic health.  
- **Databases** – That they are up and responding (e.g. ODK, Social Registry).  
- **Backups** – That backup jobs run and succeed; we get an alert if a backup fails or doesn’t run for too long (e.g. 24 hours).  
- **Applications** – That key services are reachable and responding.  
- **Logs** – Central place to search logs when investigating an issue.

---

## Where can I see the status myself?

We have a **dashboard** (Grafana) that shows:

- System and server health  
- **Backup status** – last run, success/failure, how long it took  
- Other metrics the team uses day to day  

**How to open it:** In a browser, go to: **http://\<server-ip\>:30180**  
(Your IT/DevOps team can give you the exact link and any login details.)

You don’t need to understand the technical details; the dashboards use simple labels and colours (e.g. green = OK, red = problem).

---

## What should I do when I get an alert?

- **Read the subject/title** – It usually says what failed (e.g. “Backup failed”, “Database down”).  
- **Check #alerts in Slack** – Often there is a short description and a link to more detail.  
- **Notify the technical team** if you’re not the one who fixes it – forward the email or share the Slack message.  
- **Don’t ignore “resolved”** – A “resolved” message means the issue was fixed (e.g. backup ran successfully); no action needed unless someone asks you to note it.

---

## Summary in one sentence

**We use monitoring to watch our systems 24/7 and get email and Slack alerts when something goes wrong (and when it’s fixed), so the team can react quickly.**

---

*For technical details (ports, alert rules, backup flow), see **MONITORING-SETUP-SNAPSHOT.md**.*
