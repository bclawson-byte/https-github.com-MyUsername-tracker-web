# Internal Pilot Checklist (3 users)

Use this for the first 3-5 business days of internal rollout.

## Users

- Owner user can log in and view all records.
- Two editor users can log in and create/update clients/tasks.
- Viewer role (if assigned) cannot write.

## Data flow

- New client persists after refresh.
- Task create/update/delete persists after refresh.
- Sent proposal updates are visible to all agency users.

## Security checks

- Direct query from one user only returns rows for `agency_id = alphaomega`.
- Cross-agency test rows are not visible to current users.
- Update/delete blocked for unauthorized roles.

## Reliability

- No repeated sync failure banners during normal use.
- Save latency is acceptable (<3 seconds perceived for common edits).
- Local CSV backup still downloads correctly.

## Go-live gate

- All checks pass for 3 consecutive days.
- Backup and rollback export captured.
- Team confirms Supabase path as primary workflow.
