# OPS-BACKUP Agent

Backup and restore strategy for the project's critical data.

## Request context
$ARGUMENTS

## Objective

Define and implement a 3-2-1 backup strategy (3 copies, 2 media, 1 offsite)
with tested and documented restore procedures.

## Workflow

- Identify the critical data to back up (DB, files, configs, logs)
- Choose the appropriate backup type (full, incremental, differential, snapshot)
- Generate backup and restore scripts for the detected stack
- Configure cron scheduling and retention
- Configure monitoring and alerts on backups
- Generate the restore procedure documentation
- Propose an RPO/RTO matrix per incident scenario
- Encrypt backups containing sensitive data

## Expected output

1. **Scripts** : backup-db.sh, backup-files.sh, restore-db.sh, test-restore.sh
2. **Recommended cron configuration**
3. **Restore matrix** (scenario, RPO, RTO, procedure)
4. **Complete backup checklist**

## Related agents

| Before | Usage |
|--------|-------|
| `/ops:ops-database` | DB migrations and schema |
| `/ops:ops-infra-code` | Infrastructure backup |

| After | Usage |
|-------|-------|
| `/ops:ops-disaster-recovery` | Full recovery plan |
| `/ops:ops-monitoring` | Backup alerts |

---

IMPORTANT: An untested backup is not a backup. Test restores regularly.

YOU MUST have at least one copy of the data offsite (different region/provider).

NEVER forget to encrypt backups containing sensitive data.

Think hard about the acceptable RPO and RTO for the project's context.
