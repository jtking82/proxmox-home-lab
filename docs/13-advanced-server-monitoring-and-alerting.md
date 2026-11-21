# Advanced Server Monitoring & Alerting Lab

## Objective

Extend the Debian services VM beyond basic uptime checks by collecting host-level performance metrics, reviewing alert rules, and configuring email notifications. The lab focuses on observability, safe testing, notification routing, and documenting what has—and has not—been verified.

## Environment

- Proxmox VE host running a Debian 13 (Trixie) services VM
- Docker services: Pi-hole, Uptime Kuma, and Portainer
- Netdata installed directly on the Debian VM as a system service
- Netdata dashboard available on the private LAN (the address is intentionally not published)
- Gmail SMTP relay configured through `msmtp-mta`
- Netdata notification recipient role: `sysadmin`

No LAN IP addresses, email addresses, passwords, Gmail App Passwords, or live configuration files are included in this repository.

## Work completed

### 1. Installed and validated Netdata

Netdata was installed using its official kickstart installer. The systemd service was enabled and verified running after configuration changes.

The dashboard was used to inspect host-level metrics, including:

- CPU utilization and pressure
- Memory usage
- Disk activity
- Network traffic
- System load and I/O pressure
- Active alert rules and raised-alert state

At the time of the dashboard review, Netdata showed approximately 65 running alert rules and no raised alerts. The displayed resource metrics provided a live baseline; values naturally change with workload and are not treated as fixed capacity measurements.

### 2. Reviewed a CPU utilization alert

The `10min_cpu_usage` alert was inspected. It evaluates CPU utilization using a rolling 10-minute average and checks on a one-minute interval. Its warning and critical thresholds are configured for sustained high utilization rather than a brief spike. The rule is routed to the `sysadmin` notification role.

This distinction matters operationally: a short CPU workload can be visible on a dashboard without satisfying an alert's sustained-duration threshold. Alert thresholds were not lowered merely to force a notification.

### 3. Configured Gmail email delivery

The Debian VM was configured to relay email through Gmail SMTP using `msmtp-mta`.

Configuration work included:

- Installing the `msmtp-mta` package
- Configuring the Gmail SMTP endpoint with TLS
- Using a Gmail App Password rather than an account password
- Restricting access to the SMTP configuration file
- Making the msmtp log available to the service account with restricted permissions
- Configuring Netdata's email sender and default recipient settings
- Enabling the `sysadmin` role recipient mapping to use the default recipient
- Pointing Netdata's notification script to the system sendmail-compatible wrapper

Secrets and recipient details are intentionally excluded. The SMTP configuration and Netdata notification configuration must remain private on the server.

### 4. Verified notification delivery

The Netdata notification test was run under the Netdata service account:

```bash
sudo -u netdata env NETDATA_ALARM_NOTIFY_DEBUG=1 \
  /usr/libexec/netdata/plugins.d/alarm-notify.sh test
```

The test generated three notification emails, all of which were received. This verifies that the notification script can execute as the Netdata account and that the configured email delivery path is functioning.

**Important scope note:** This was Netdata's built-in test notification. It was not a real CPU alert.

### 5. Performed a controlled CPU workload test

A short CPU workload was generated with an automatic 30-second limit:

```bash
timeout 30s yes > /dev/null
```

The command intentionally produces no terminal output because standard output is redirected to `/dev/null`. The workload was observed in Netdata, where CPU activity/pressure visibly increased during the test.

The workload demonstrated that Netdata was collecting and displaying the resulting activity. It did not produce a confirmed CPU alert or a real-alert email. A 30-second workload is brief relative to the rule's rolling 10-minute evaluation window and is not expected to satisfy its sustained high-utilization condition.

## Validation results

| Check | Result | Evidence / notes |
|---|---|---|
| Netdata installed | Pass | Dashboard accessible |
| Netdata service enabled and running | Pass | Service restarted after notification configuration; active state confirmed |
| Host metrics collection | Pass | CPU, memory, disk, network, and pressure metrics visible |
| Alert rules loaded | Pass | Approximately 65 running rules observed |
| CPU alert reviewed | Pass | `10min_cpu_usage` rule inspected |
| SMTP relay test | Pass | SMTP accepted test messages |
| Netdata notification test | Pass | Three emails received |
| CPU workload visibility | Pass | 30-second workload produced a visible dashboard spike |
| Real CPU alert raised | Not yet verified | Alert remained clear; workload did not meet the sustained threshold |
| Email from a real CPU alert | Not yet verified | No real alert was triggered |

## Operational notes and troubleshooting

- A command such as `timeout 30s yes > /dev/null` runs silently by design. The absence of terminal output does not mean the workload failed.
- Use a second terminal with `top` or the Netdata dashboard to observe CPU activity while the workload runs.
- A visible graph spike is not the same as an alert. Alert rules evaluate configured conditions and time windows.
- Do not reduce production alert thresholds simply to generate a test email. Use a controlled, reversible test method and restore any temporary configuration afterward.
- AppArmor was already active on the Debian VM; no AppArmor change was required for this lab.
- A generic network-interface drop counter was observed during baseline collection, but driver-level `ethtool` statistics showed no corresponding RX drops or TX timeouts. This was recorded as an observation, not diagnosed as a network fault.

## Security considerations

- Keep SMTP credentials and Gmail App Passwords out of Git, screenshots, terminal transcripts, and public issue reports.
- Keep `/etc/msmtprc` and Netdata notification configuration readable only by the accounts that require access.
- Do not publish recipient email addresses, LAN addresses, or unredacted configuration files.
- Use a dedicated App Password and revoke it if it is exposed.
- Do not expose the Netdata dashboard or administrative services directly to the public internet.

## Remaining work

- [ ] Design and perform a safe, controlled test that raises a real Netdata alert.
- [ ] Confirm that a real alert routed to `sysadmin` generates an email.
- [ ] Verify alert recovery/clear notifications, if configured.
- [ ] Review alert thresholds and notification noise after observing normal operation.
- [ ] Add sanitized screenshots or command evidence only after reviewing them for secrets and identifying details.

## Skills practiced

Linux service administration with systemd, monitoring and observability, interpreting CPU and system-pressure metrics, alert-rule inspection, SMTP configuration, TLS-based email relay, service-account permissions, notification routing, controlled workload generation, and operational documentation.
