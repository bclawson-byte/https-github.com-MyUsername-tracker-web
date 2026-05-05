# Lightspeed Voice Pilot Test Checklist

## Browser and agent readiness

- [ ] Chrome is used for pilot reps.
- [ ] Headset/mic permissions granted.
- [ ] CRM `Phone (Lightspeed Voice)` settings filled.
- [ ] Lightspeed dashboard launches from the CRM phone button.
- [ ] CTI API base URL is set to worker endpoint.
- [ ] Embedded calling toggle is ON.

## Outbound tests

- [ ] Click call icon on a client with phone number.
- [ ] CRM shows call launched -> in call status updates.
- [ ] Activity log shows call entries.
- [ ] Completed `Call` task appears in Tasks view.
- [ ] Hangup button in CRM ends active call (when provider adapter is configured).

## Inbound tests

- [ ] Call Lightspeed-assigned number from external phone.
- [ ] Inbound call is handled in Lightspeed native client.
- [ ] Rep records outcome in CRM activity/task stream.

## Failure/edge tests

- [ ] Missing phone on client shows warning (no call attempt).
- [ ] Missing dashboard URL shows clear warning in CRM.
- [ ] Missing API credentials returns scaffold error (expected until configured).
- [ ] Rep can still complete calls directly in Lightspeed.

## Rollback steps (same day)

- [ ] Turn off `Auto-open Lightspeed dashboard on load`.
- [ ] Clear `Lightspeed dashboard URL` in settings if pilot is paused.
- [ ] Continue fallback call handling outside CRM.
