# Twilio CTI Pilot Runbook (1-3 reps)

## 1) Create Twilio resources

1. Create a Twilio account and verify the owner number.
2. Buy one voice-capable number in Twilio Console.
3. Create a TwiML App:
   - Voice webhook URL: `https://<your-worker-domain>/twilio/voice`
   - HTTP method: `POST`
4. Create an API Key + Secret (standard key).

## 2) Configure Worker secrets

In `claude-proxy`, set:

- `TWILIO_ACCOUNT_SID`
- `TWILIO_API_KEY`
- `TWILIO_API_SECRET`
- `TWILIO_TWIML_APP_SID`
- `TWILIO_CALLER_ID` (E.164, usually the purchased number)
- `TWILIO_INBOUND_CLIENT_IDENTITY` (agent identity for pilot, example: `baruch`)
- `TWILIO_RECORD_CALLS` (`1` to enable at TwiML level, otherwise `0`)
- `TWILIO_TOKEN_TTL_SECONDS` (recommended `3600`)

## 3) Point Twilio number inbound to Worker

For the purchased number:

- A call comes in:
  - Webhook URL: `https://<your-worker-domain>/twilio/voice`
  - Method: `POST`

Optional status callbacks:

- Status callback URL: `https://<your-worker-domain>/twilio/status`
- Method: `POST`

## 4) CRM settings for pilot reps

Open CRM Settings -> `Phone (Twilio CTI Pilot)`:

- CTI API base URL: `https://<your-worker-domain>`
- Agent identity: per-rep value (`baruch`, `rep2`, etc.)
- Caller ID: E.164 number
- Auto-register softphone on load: on (recommended for pilot)
- Call recording: optional toggle for pilot only

## 5) Test checklist

1. Click phone button in hero bar -> softphone registers.
2. Open client with phone -> click call icon -> outbound call connects.
3. Confirm log entries appear on client activity timeline.
4. Place inbound call to Twilio number -> verify screen opens matched client when phone exists.
5. Hang up using CRM control and verify completion logs.

## 6) Pilot rollback

If issues occur:

1. Disable auto-register in settings.
2. Clear CTI API base URL in settings.
3. Keep workflow fallback: standard `tel:` call from phone/mobile.
