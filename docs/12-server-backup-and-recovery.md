# Server Backup & Recovery Lab

## Objective

Build and validate a repeatable backup workflow for persistent data and deployment information from three Docker-hosted services on a Debian server: Pi-hole, Uptime Kuma, and Portainer.

## Environment and scope

- Debian Linux server running Docker Engine
- Pi-hole, Uptime Kuma, and Portainer
- Bash backup script
- Root-managed backup directory and script
- Daily scheduled backup using root's cron
- Local storage only (off-host backup is a future improvement)

## What was backed up

| Service | Data source | Archive |
|---|---|---|
| Pi-hole | Persistent configuration directory | `pihole.tar.gz` |
| Uptime Kuma | Docker volume data | `uptime-kuma.tar.gz` |
| Portainer | Docker volume data | `portainer.tar.gz` |

The backup also saves the Pi-hole Compose file and Docker inspection snapshots for all three containers. These inspection files and archives can contain sensitive information and are **not** committed to this public repository.

## Workflow

1. Confirm that the expected containers exist.
2. Stop the containers briefly to reduce the risk of capturing inconsistent application data.
3. Archive each application's persistent data.
4. Save deployment configuration and Docker inspection snapshots.
5. Restart the containers.
6. Generate SHA-256 checksums and a manifest.
7. Update the `latest` symbolic link.
8. Remove dated backup directories older than the configured retention period.

## Script and storage

- Script: `/home/jtadmin/backups/backup-docker.sh`
- Backup root: `/home/jtadmin/backups/docker-backups`
- Latest backup: `docker-backups/latest`
- Retention: 14 days
- Schedule: daily at 02:00 via root crontab
- Log: `/home/jtadmin/backups/backup.log`

Cron entry:

```cron
0 2 * * * /bin/bash /home/jtadmin/backups/backup-docker.sh >> /home/jtadmin/backups/backup.log 2>&1
```

## Security controls

The backup script is owned by root and restricted to mode 700. The backup storage directory is root-owned and restricted to mode 700. Backups include application databases and configuration, and may include secrets; access is intentionally restricted.

## Validation performed

- [x] Script executed manually and reported successful completion
- [x] SHA-256 checksums generated
- [x] Checksum verification completed successfully for archives, Compose file, and Docker inspection snapshots
- [x] Archive contents inspected
- [x] Pi-hole archive extracted into a separate recovery-test directory and inspected
- [x] Uptime Kuma and Portainer extraction tests completed
- [x] Containers verified running after the backup operation
- [x] Cron schedule installed in root's crontab
- [x] Script and backup directory permissions hardened
- [x] 14-day retention policy added to script

**Recovery test scope:** These were archive integrity and extraction tests, not a full application restore onto a replacement server. The backup is currently stored on the same host and disk, so it does not protect against host or disk failure.

## Useful verification commands

Check container status:

```bash
docker ps
```

Verify the latest backup checksums:

```bash
sudo bash -c 'cd "$(readlink -f /home/jtadmin/backups/docker-backups/latest)" && sha256sum -c checksums.sha256'
```

List archive contents without extracting:

```bash
sudo tar -tzf ~/backups/docker-backups/latest/pihole.tar.gz
sudo tar -tzf ~/backups/docker-backups/latest/uptime-kuma.tar.gz
sudo tar -tzf ~/backups/docker-backups/latest/portainer.tar.gz
```

Inspect the backup log:

```bash
sudo tail -n 50 /home/jtadmin/backups/backup.log
```

## Next improvements

- Copy backups to a separate physical device or remote system.
- Test a complete restore of one service in an isolated environment.
- Confirm cron execution from the log after the first scheduled run.
- Review and securely manage application secrets in deployment configuration.

## Skills practiced

Linux filesystem and permissions, Bash scripting, Docker container lifecycle management, persistent-volume identification, archive creation and extraction, checksum verification, cron scheduling, retention automation, recovery planning, and technical documentation.
