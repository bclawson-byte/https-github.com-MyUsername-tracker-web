export default {
    async fetch(request, env) {
      const corsHeaders = {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type",
      };
  
      if (request.method === "OPTIONS") {
        return new Response(null, { headers: corsHeaders });
      }
  
      if (request.method !== "POST") {
        return new Response("Use POST", { status: 405, headers: corsHeaders });
      }
  
      try {
        const body = await request.json();
        const prompt = body.prompt;
        if (!prompt) {
          return new Response(JSON.stringify({ error: "Missing prompt" }), {
            status: 400,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
          });
        }
  
        const r = await fetch("https://api.anthropic.com/v1/messages", {
          method: "POST",
          headers: {
            "x-api-key": env.ANTHROPIC_API_KEY,
            "anthropic-version": "2023-06-01",
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            model: "claude-haiku-4-5-20251001",
            max_tokens: 1024,
            messages: [{ role: "user", content: prompt }],
          }),
        });
  
        const data = await r.json();
        if (!r.ok) {
          return new Response(JSON.stringify({ error: data }), {
            status: r.status,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
          });
        }
  
        const text = (data.content && data.content[0] && data.content[0].text) || "";
        return new Response(JSON.stringify({ text }), {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      } catch (e) {
        return new Response(JSON.stringify({ error: e.message }), {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }
    },
  };