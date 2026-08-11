# 2x00 — Locking the Gates (MedDefense Infrastructure Hardening)

CIS-Benchmark-based hardening of MedDefense's three Linux servers
(`billing-srv-01`, `web-srv-01`, `log-srv-01`, all Ubuntu 22.04).

The deliverable is **scripts, not reports**. Every hardening action is captured
in an idempotent bash script that produces a measurable state change and/or a
structured JSON artifact. The delta between the pre-hardening baseline and the
post-hardening state is the proof of work.

## Files

| File | Purpose |
|------|---------|
| `0-baseline_snapshot.sh` | Capture the complete pre-hardening security state (system ID, services, ports, SUID/SGID, world-writable files, sysctl, SSH config, users/sudo). Emits a human summary + `baseline_snapshot.json`. Read-only. |

## Conventions

- Every script starts with `#!/bin/bash` and is executable (`chmod +x`).
- Scripts are **idempotent**: re-running produces an equivalent result.
- Structured data is emitted as JSON to `/var/log/meddefense/` (falls back to
  the current directory if that path is not writable).
- Comments reference the MedDefense finding or Crimson Tide phase each action
  addresses (e.g. Finding 009 = SSH password auth).

## Usage

```bash
sudo ./0-baseline_snapshot.sh
```

Run this on each target **before** applying any hardening task so the later
diff/validation tasks have a baseline to measure against.
