# Lightspeed Voice Pilot Runbook (1-3 reps)

## 1) Confirm Lightspeed tenant readiness

1. Verify active Lightspeed Voice logins for pilot reps.
2. Confirm existing numbers/extensions are assigned correctly.
3. Confirm Orbit/desktop app (or Lightspeed web dialer) is installed and signed in for pilot reps.

## 2) CRM settings for pilot reps

Open CRM Settings -> `Phone (Lightspeed Voice)`:

- CTI API base URL (proxy/worker): your deployed worker URL (`https://...workers.dev`).
- Lightspeed dashboard URL: the URL your reps use daily.
- Agent login / extension: rep login or extension value.
- Caller ID: E.164 format.
- In-CRM embedded calling (API): enable for true dial/hangup from CRM.
- Auto-open Lightspeed dashboard on load: recommended for pilot.
- Add recording note marker: optional for audit trail.

## 3) Worker env scaffold (required for embedded mode)

Configure these env vars in `claude-proxy`:

- `LIGHTSPEED_API_BASE_URL`
- `LIGHTSPEED_API_TOKEN`
- `LIGHTSPEED_OUTBOUND_PATH` (default scaffold: `/api/calls`)
- `LIGHTSPEED_HANGUP_PATH_TEMPLATE` (default scaffold: `/api/calls/{call_id}/hangup`)
- `LIGHTSPEED_AUTH_HEADER` (default `Authorization`)
- `LIGHTSPEED_AUTH_PREFIX` (default `Bearer `)

If credentials are missing, the CRM will show a scaffold error and will not place in-CRM calls.

## 4) Day-of pilot operation

1. Rep opens CRM and clicks the phone icon in header to launch Lightspeed.
2. Rep clicks a client call icon in pipeline card.
3. CRM sends `POST /lightspeed/calls` via worker.
4. Rep can end active call from CRM (hangup button) when provider adapter is configured.
5. CRM writes call activity/task entries.

## 5) Inbound call handling (native-first)

- Inbound call pop and routing stay in Lightspeed as system of record.
- Reps update/match the corresponding client record in CRM if needed.
- Activity entries can be added from card notes to capture outcomes.

## 6) Pilot rollback

If issues occur:

1. Disable `Auto-open Lightspeed dashboard on load`.
2. Keep manual calling in Lightspeed only.
3. Keep CRM updates to notes/tasks until adjustments are made.
