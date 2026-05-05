# Twilio CTI Pilot Test Checklist

## Browser and agent readiness

- [ ] Chrome is used for pilot reps.
- [ ] Headset/mic permissions granted.
- [ ] CRM `Phone (Twilio CTI Pilot)` settings filled.
- [ ] Softphone state shows `Phone: ready`.

## Outbound tests

- [ ] Click call icon on a client with phone number.
- [ ] Call transitions: dialing -> in call -> completed.
- [ ] Activity log shows call entries.
- [ ] Completed `Call` task appears in Tasks view.

## Inbound tests

- [ ] Call Twilio number from external phone.
- [ ] If phone matches a client, card opens automatically.
- [ ] Inbound call logs on matched client.
- [ ] Hang up path returns to `Phone: ready`.

## Failure/edge tests

- [ ] Missing phone on client shows warning (no call attempt).
- [ ] Token endpoint misconfig shows clear error in CTI bar.
- [ ] Manual hangup button ends active call.

## Rollback steps (same day)

- [ ] Turn off `Auto-register softphone on load`.
- [ ] Clear `CTI API base URL` in settings if pilot is paused.
- [ ] Continue fallback call handling outside CRM.
