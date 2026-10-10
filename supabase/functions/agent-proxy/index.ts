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

  const authorization = request.headers.get('Authorization') ?? ''
  if (!authorization.startsWith('Bearer ') || !authorization.slice(7).trim()) {
    return jsonResponse({error: 'Authentication required'}, 401)
  }
  const supabaseUrl = Deno.env.get('SUPABASE_URL')
  const supabaseAnonKey = Deno.env.get('SUPABASE_ANON_KEY')
  if (!supabaseUrl || !supabaseAnonKey) {
    return jsonResponse({error: 'Authentication is not configured'}, 500)
  }
  try {
    const authResponse = await fetch(`${supabaseUrl}/auth/v1/user`, {
      headers: {Authorization: authorization, apikey: supabaseAnonKey},
    })
    if (!authResponse.ok) {
      return jsonResponse({error: 'Authentication required'}, 401)
    }
    const user = await authResponse.json()
    if (typeof user?.id !== 'string' || !user.id) {
      return jsonResponse({error: 'Authentication required'}, 401)
    }
  } catch (_) {
    return jsonResponse({error: 'Authentication unavailable'}, 503)
  }

  let payload: Record<string, unknown>
  try {
    payload = await request.json()
  } catch (_) {
    return jsonResponse({error: 'Invalid JSON'}, 400)
  }

  if (!payload || typeof payload !== 'object' || Array.isArray(payload)) {
    return jsonResponse({error: 'Invalid JSON object'}, 400)
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

  const isReceiptScan = payload.action === 'receipt_scan'
  const isExpenseParse = payload.action === 'expense_parse'
  if (!isReceiptScan && !isExpenseParse && (
    payload.action !== 'chat' ||
    !Array.isArray(payload.messages) ||
    !payload.messages.length
  )) {
    return jsonResponse({error: 'Invalid chat payload'}, 400)
  }

  const apiKey = Deno.env.get('AGENT_API_KEY')
  if (!apiKey) {
    return jsonResponse({error: 'Agent is not configured'}, 500)
  }

  let agentPayload: Record<string, unknown>
  if (isReceiptScan || isExpenseParse) {
    const image = typeof payload.image === 'string' ? payload.image : ''
    const categories = Array.isArray(payload.category_codes)
      ? payload.category_codes.filter((value) => typeof value === 'string')
      : []
    const currentDate = typeof payload.current_date === 'string' &&
        /^\d{4}-\d{2}-\d{2}$/.test(payload.current_date)
      ? payload.current_date
      : new Date().toISOString().slice(0, 10)
    const selectedDate = typeof payload.selected_date === 'string' &&
        /^\d{4}-\d{2}-\d{2}$/.test(payload.selected_date)
      ? payload.selected_date : currentDate
    const text = typeof payload.text === 'string' ? payload.text.trim() : ''
    if (
      (isReceiptScan && (!image || image.length > 4 * 1024 * 1024 ||
        image.length % 4 !== 0 || !/^[A-Za-z0-9+/]+={0,2}$/.test(image))) ||
      (isExpenseParse && (!text || text.length > 10000)) ||
      !categories.length || categories.length > 200 ||
      categories.some((code) => code.length > 200)
    ) {
      return jsonResponse({error: 'Invalid expense payload'}, 400)
    }
    agentPayload = {
      model: Deno.env.get('AGENT_MODEL') ?? 'agnes-2.0-flash',
      temperature: 0,
      max_tokens: 1024,
      response_format: {type: 'json_object'},
      chat_template_kwargs: {enable_thinking: false},
      stream: false,
      messages: [{
        role: 'user',
        content: [
          {
            type: 'text',
            text: `Extract transaction details from this Indonesian ${isReceiptScan ? 'receipt' : 'text'} and return JSON only:\n{"note":"merchant or short purchase title","detail":"important items or empty string","category":"one category code","amount":number,"date":"YYYY-MM-DD"}\nUse a whole number of rupiah for amount. Interpret k/rb as thousands and M/jt as millions. Resolve relative dates such as yesterday from the current date. Use ${isExpenseParse ? selectedDate : currentDate} when no date is given. Choose only from the supplied category codes.\nCurrent date: ${currentDate}\nCategory codes: ${categories.join(', ')}${isExpenseParse ? `\nTransaction text: ${text}` : ''}`,
          },
          ...(isReceiptScan ? [{
            type: 'image_url',
            image_url: {url: `data:image/jpeg;base64,${image}`},
          }] : []),
        ],
      }],
    }
  } else {
    agentPayload = {
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
  if (isReceiptScan || isExpenseParse) {
    try {
      return jsonResponse(await response.json(), 200)
    } catch (_) {
      return jsonResponse({error: 'Agent returned an invalid response'}, 502)
    }
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
