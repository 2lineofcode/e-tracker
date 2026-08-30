const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, apikey, content-type, x-client-info',
}

const jsonResponse = (body: unknown, status: number) =>
  Response.json(body, {status, headers: corsHeaders})

Deno.serve(async (request) => {
  if (request.method === 'OPTIONS') {
    return new Response(null, {status: 204, headers: corsHeaders})
  }
  if (request.method !== 'POST') {
    return jsonResponse({error: 'Method not allowed'}, 405)
  }

  let payload: Record<string, unknown>
  try {
    payload = await request.json()
  } catch (_) {
    return jsonResponse({error: 'Invalid JSON'}, 400)
  }

  if (payload.action === 'web_search') {
    const query = typeof payload.query === 'string' ? payload.query.trim() : ''
    if (!query || query.length > 300) {
      return jsonResponse({error: 'Invalid query'}, 400)
    }
    const url = `https://www.bing.com/search?format=rss&setlang=id-ID&q=${encodeURIComponent(query)}`
    const response = await fetch(url, {
      headers: {'User-Agent': 'Mozilla/5.0 ExpenseTracker/1.0'},
    })
    if (!response.ok) {
      return jsonResponse({error: 'Web search failed'}, 502)
    }
    return jsonResponse({xml: await response.text()}, 200)
  }

  if (
    payload.action !== 'chat' ||
    !Array.isArray(payload.messages) ||
    !payload.messages.length
  ) {
    return jsonResponse({error: 'Invalid chat payload'}, 400)
  }

  const apiKey = Deno.env.get('AGENT_API_KEY')
  if (!apiKey) {
    return jsonResponse({error: 'Agent is not configured'}, 500)
  }

  const agentPayload: Record<string, unknown> = {
    model: Deno.env.get('AGENT_MODEL') ?? 'agnes-2.0-flash',
    messages: payload.messages,
    temperature: 0.2,
    max_tokens: 65536,
    chat_template_kwargs: {enable_thinking: false},
    stream: true,
  }
  if (Array.isArray(payload.tools)) {
    agentPayload.tools = payload.tools
    agentPayload.tool_choice = payload.tool_choice ?? 'auto'
  }

  const response = await fetch(
    Deno.env.get('AGENT_BASE_URL') ??
      'https://apihub.agnes-ai.com/v1/chat/completions',
    {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(agentPayload),
    },
  )
  if (!response.ok || !response.body) {
    return jsonResponse({error: 'Agent request failed'}, 502)
  }

  return new Response(response.body, {
    status: 200,
    headers: {
      ...corsHeaders,
      'Cache-Control': 'no-cache',
      'Content-Type': response.headers.get('Content-Type') ?? 'text/event-stream',
    },
  })
})
