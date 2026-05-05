const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, X-Requested-With",
};

const DEFAULT_MODEL = "claude-haiku-4-5-20251001";
const DEFAULT_MAX_TOKENS = 4096;
const HARD_MAX_TOKENS = 8192;

function jsonResponse(payload, status = 200, extraHeaders = {}) {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { ...CORS_HEADERS, "Content-Type": "application/json", ...extraHeaders },
  });
}

function textResponse(text, status = 200, extraHeaders = {}) {
  return new Response(text, { status, headers: { ...CORS_HEADERS, ...extraHeaders } });
}

function getString(input) {
  return typeof input === "string" ? input.trim() : "";
}

function assertTwilioEnv(env) {
  const missing = [];
  if (!getString(env.TWILIO_ACCOUNT_SID)) missing.push("TWILIO_ACCOUNT_SID");
  if (!getString(env.TWILIO_API_KEY)) missing.push("TWILIO_API_KEY");
  if (!getString(env.TWILIO_API_SECRET)) missing.push("TWILIO_API_SECRET");
  if (!getString(env.TWILIO_TWIML_APP_SID)) missing.push("TWILIO_TWIML_APP_SID");
  return missing;
}

function base64UrlEncode(inputBytes) {
  const base64 = btoa(String.fromCharCode(...new Uint8Array(inputBytes)));
  return base64.replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/g, "");
}

async function hmacSha256(secret, payload) {
  const enc = new TextEncoder();
  const key = await crypto.subtle.importKey(
    "raw",
    enc.encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"]
  );
  const signature = await crypto.subtle.sign("HMAC", key, enc.encode(payload));
  return base64UrlEncode(signature);
}

async function makeTwilioAccessToken(env, identity) {
  const accountSid = getString(env.TWILIO_ACCOUNT_SID);
  const apiKey = getString(env.TWILIO_API_KEY);
  const apiSecret = getString(env.TWILIO_API_SECRET);
  const appSid = getString(env.TWILIO_TWIML_APP_SID);
  const ttlSeconds = Math.max(300, Math.min(86400, Number(env.TWILIO_TOKEN_TTL_SECONDS) || 3600));
  const nowSec = Math.floor(Date.now() / 1000);
  const exp = nowSec + ttlSeconds;
  const safeIdentity = identity.replace(/[^a-zA-Z0-9_\-@.]/g, "_").slice(0, 121) || "agent";
  const jti = `${apiKey}-${Date.now()}-${Math.random().toString(36).slice(2, 10)}`;

  const header = { typ: "JWT", alg: "HS256", cty: "twilio-fpa;v=1" };
  const payload = {
    jti,
    iss: apiKey,
    sub: accountSid,
    nbf: nowSec,
    exp,
    grants: {
      identity: safeIdentity,
      voice: {
        incoming: { allow: true },
        outgoing: {
          application_sid: appSid,
          params: { identity: safeIdentity },
        },
      },
    },
  };

  const encodedHeader = base64UrlEncode(new TextEncoder().encode(JSON.stringify(header)));
  const encodedPayload = base64UrlEncode(new TextEncoder().encode(JSON.stringify(payload)));
  const signingInput = `${encodedHeader}.${encodedPayload}`;
  const signature = await hmacSha256(apiSecret, signingInput);
  return `${signingInput}.${signature}`;
}

async function handleClaudeProxy(request, env) {
  if (request.method !== "POST") {
    return textResponse("Use POST", 405);
  }
  const body = await request.json();
  const prompt = body.prompt;
  if (!prompt) return jsonResponse({ error: "Missing prompt" }, 400);

  const requestedModel = getString(body.model) || DEFAULT_MODEL;
  let requestedMaxTokens = Number(body.max_tokens);
  if (!Number.isFinite(requestedMaxTokens) || requestedMaxTokens <= 0) requestedMaxTokens = DEFAULT_MAX_TOKENS;
  if (requestedMaxTokens > HARD_MAX_TOKENS) requestedMaxTokens = HARD_MAX_TOKENS;

  const r = await fetch("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: {
      "x-api-key": env.ANTHROPIC_API_KEY,
      "anthropic-version": "2023-06-01",
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model: requestedModel,
      max_tokens: requestedMaxTokens,
      messages: [{ role: "user", content: prompt }],
    }),
  });
  const data = await r.json();
  if (!r.ok) return jsonResponse({ error: data }, r.status);
  const text = (data.content && data.content[0] && data.content[0].text) || "";
  return jsonResponse({ text });
}

async function handleTwilioToken(request, env) {
  if (request.method !== "POST") return textResponse("Use POST", 405);
  const missing = assertTwilioEnv(env);
  if (missing.length) return jsonResponse({ error: "Missing Twilio env vars", missing }, 500);

  let identity = "";
  try {
    const body = await request.json();
    identity = getString(body && body.identity);
  } catch {
    identity = "";
  }
  if (!identity) return jsonResponse({ error: "Missing identity" }, 400);

  const token = await makeTwilioAccessToken(env, identity);
  return jsonResponse({
    token,
    identity: identity.replace(/[^a-zA-Z0-9_\-@.]/g, "_").slice(0, 121) || "agent",
    expires_in: Math.max(300, Math.min(86400, Number(env.TWILIO_TOKEN_TTL_SECONDS) || 3600)),
  });
}

async function handleTwilioStatus(request) {
  if (request.method !== "POST") return textResponse("Use POST", 405);
  const data = Object.fromEntries((await request.formData()).entries());
  return jsonResponse({
    ok: true,
    call_sid: getString(data.CallSid),
    event_type: getString(data.CallStatus || data.CallEvent || "status"),
    direction: getString(data.Direction),
    from: getString(data.From),
    to: getString(data.To),
    timestamp: new Date().toISOString(),
  });
}

async function handleTwilioVoice(request, env) {
  if (request.method !== "POST") return textResponse("Use POST", 405);
  const data = Object.fromEntries((await request.formData()).entries());
  const to = getString(data.To);
  const incomingTo = getString(data.Called || data.To);
  const defaultCallerId = getString(env.TWILIO_CALLER_ID) || incomingTo;
  const inboundClient = getString(env.TWILIO_INBOUND_CLIENT_IDENTITY) || "agent";
  const shouldRecord = getString(env.TWILIO_RECORD_CALLS) === "1" ? ' record="record-from-answer"' : "";

  let twiml = "";
  if (to && /^[+0-9().\-\s]{7,}$/.test(to)) {
    const e164 = to.replace(/[^\d+]/g, "");
    twiml = `<?xml version="1.0" encoding="UTF-8"?><Response><Dial callerId="${defaultCallerId}"${shouldRecord}><Number>${e164}</Number></Dial></Response>`;
  } else {
    twiml = `<?xml version="1.0" encoding="UTF-8"?><Response><Dial${shouldRecord}><Client>${inboundClient}</Client></Dial></Response>`;
  }
  return textResponse(twiml, 200, { "Content-Type": "text/xml; charset=utf-8" });
}

function assertLightspeedEnv(env) {
  const missing = [];
  if (!getString(env.LIGHTSPEED_API_BASE_URL)) missing.push("LIGHTSPEED_API_BASE_URL");
  if (!getString(env.LIGHTSPEED_API_TOKEN)) missing.push("LIGHTSPEED_API_TOKEN");
  return missing;
}

function parseLightspeedCallId(pathname) {
  const parts = pathname.split("/").filter(Boolean);
  if (parts.length >= 3 && parts[0] === "lightspeed" && parts[1] === "calls") return parts[2];
  return "";
}

async function callLightspeedApi(env, path, payload) {
  const base = getString(env.LIGHTSPEED_API_BASE_URL).replace(/\/+$/, "");
  const token = getString(env.LIGHTSPEED_API_TOKEN);
  const authHeader = getString(env.LIGHTSPEED_AUTH_HEADER) || "Authorization";
  const authValuePrefix = getString(env.LIGHTSPEED_AUTH_PREFIX) || "Bearer ";
  const url = base + path;
  return await fetch(url, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      [authHeader]: authValuePrefix + token,
    },
    body: JSON.stringify(payload || {}),
  });
}

async function handleLightspeedCallCreate(request, env) {
  if (request.method !== "POST") return textResponse("Use POST", 405);
  const missing = assertLightspeedEnv(env);
  if (missing.length) {
    return jsonResponse({
      ok: false,
      error: "Lightspeed API bridge scaffold is ready, but credentials are not configured.",
      missing,
      expected_paths: {
        create_call: "/lightspeed/calls",
        hangup: "/lightspeed/calls/{call_id}/hangup",
        webhook: "/lightspeed/webhook",
      },
    }, 501);
  }
  const body = await request.json().catch(() => ({}));
  const outboundPath = getString(env.LIGHTSPEED_OUTBOUND_PATH) || "/api/calls";
  const upstreamPayload = {
    to: getString(body.to),
    caller_id: getString(body.caller_id),
    agent_identity: getString(body.agent_identity),
    client_name: getString(body.client_name),
    metadata: {
      source: "alpha-omega-crm",
      recording_requested: !!body.recording_requested,
    },
  };
  const upstream = await callLightspeedApi(env, outboundPath, upstreamPayload);
  const data = await upstream.json().catch(() => ({}));
  if (!upstream.ok) return jsonResponse({ ok: false, error: "Lightspeed call create failed", upstream: data }, upstream.status);
  const callId = getString(data.call_id || data.callId || data.id || data.session_id);
  return jsonResponse({ ok: true, call_id: callId, status: getString(data.status) || "initiated", raw: data });
}

async function handleLightspeedHangup(request, env, callId) {
  if (request.method !== "POST") return textResponse("Use POST", 405);
  const missing = assertLightspeedEnv(env);
  if (missing.length) return jsonResponse({ ok: false, error: "Lightspeed credentials missing", missing }, 501);
  if (!callId) return jsonResponse({ ok: false, error: "Missing call id" }, 400);
  const template = getString(env.LIGHTSPEED_HANGUP_PATH_TEMPLATE) || "/api/calls/{call_id}/hangup";
  const hangupPath = template.replace("{call_id}", encodeURIComponent(callId));
  const upstream = await callLightspeedApi(env, hangupPath, { action: "hangup" });
  const data = await upstream.json().catch(() => ({}));
  if (!upstream.ok) return jsonResponse({ ok: false, error: "Lightspeed hangup failed", upstream: data }, upstream.status);
  return jsonResponse({ ok: true, call_id: callId, status: getString(data.status) || "completed", raw: data });
}

async function handleLightspeedWebhook(request) {
  if (request.method !== "POST") return textResponse("Use POST", 405);
  let data = {};
  const contentType = getString(request.headers.get("content-type")).toLowerCase();
  if (contentType.includes("application/json")) {
    data = await request.json().catch(() => ({}));
  } else {
    data = Object.fromEntries((await request.formData()).entries());
  }
  return jsonResponse({
    ok: true,
    provider: "lightspeed",
    call_id: getString(data.call_id || data.callId || data.id || data.session_id),
    event_type: getString(data.event || data.status || data.type || "status"),
    direction: getString(data.direction),
    from: getString(data.from || data.source),
    to: getString(data.to || data.destination),
    timestamp: new Date().toISOString(),
    raw: data,
  });
}

export default {
  async fetch(request, env) {
    if (request.method === "OPTIONS") return new Response(null, { headers: CORS_HEADERS });
    try {
      const url = new URL(request.url);
      const lsCallId = parseLightspeedCallId(url.pathname);
      if (url.pathname === "/lightspeed/calls") return await handleLightspeedCallCreate(request, env);
      if (lsCallId && url.pathname.endsWith("/hangup")) return await handleLightspeedHangup(request, env, lsCallId);
      if (url.pathname === "/lightspeed/webhook") return await handleLightspeedWebhook(request);
      if (url.pathname === "/twilio/token") return await handleTwilioToken(request, env);
      if (url.pathname === "/twilio/status") return await handleTwilioStatus(request);
      if (url.pathname === "/twilio/voice") return await handleTwilioVoice(request, env);
      return await handleClaudeProxy(request, env);
    } catch (e) {
      return jsonResponse({ error: e && e.message ? e.message : String(e) }, 500);
    }
  },
};