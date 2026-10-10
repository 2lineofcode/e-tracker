let handler: (request: Request) => Promise<Response>
const serve = Deno.serve
Object.defineProperty(Deno, 'serve', {
  value: (callback: typeof handler) => {handler = callback},
})
await import('./index.ts')
Object.defineProperty(Deno, 'serve', {value: serve})

Deno.test('expense parsing uses server credentials and returns JSON', async () => {
  const originalFetch = globalThis.fetch
  const originalEnvGet = Deno.env.get
  let upstream: Record<string, unknown> = {}
  Object.defineProperty(Deno.env, 'get', {
    value: (key: string) => ({
      AGENT_API_KEY: 'test-server-key', SUPABASE_URL: 'http://test-auth',
      SUPABASE_ANON_KEY: 'test-anon-key',
    } as Record<string, string>)[key],
  })
  let paidRequests = 0
  globalThis.fetch = async (input, init) => {
    if (String(input) === 'http://test-auth/auth/v1/user') {
      const headers = init!.headers as Record<string, string>
      if (headers.apikey !== 'test-anon-key') throw Error('Invalid auth API key')
      return headers.Authorization === 'Bearer user-session'
        ? Response.json({id: 'signed-in-user'})
        : Response.json({error: 'Invalid user'}, {status: 401})
    }
    paidRequests++
    upstream = JSON.parse(init!.body as string)
    if ((init!.headers as Record<string, string>)['Authorization'] !== 'Bearer test-server-key') {
      throw Error('Missing server credential')
    }
    return Response.json({choices: [{message: {content: '{"amount":12500}'}}]})
  }
  try {
    const response = await handler(new Request('http://localhost', {
      method: 'POST', headers: {Authorization: 'Bearer user-session'},
      body: JSON.stringify({action: 'expense_parse', text: 'Makan 12.5rb',
        current_date: '2026-10-10', selected_date: '2026-09-15', category_codes: ['expense:basic:food']}),
    }))
    if (response.status !== 200 || upstream.stream !== false ||
        (upstream.response_format as Record<string, unknown>).type !== 'json_object') {
      throw Error('Expense parse must return non-streaming JSON')
    }
    const prompt = JSON.stringify(upstream.messages)
    if (!prompt.includes('Use 2026-09-15 when no date is given') ||
        !prompt.includes('Current date: 2026-10-10') ||
        !prompt.includes('Resolve relative dates such as yesterday from the current date')) {
      throw Error('Selected date and relative-date context must stay distinct')
    }
    const body = await response.json()
    if (body.choices[0].message.content !== '{"amount":12500}') {
      throw Error('Upstream response was lost')
    }
    for (const payload of [null, [], {action: 'expense_parse', text: '',
      category_codes: ['expense:basic:food']}]) {
      const invalid = await handler(new Request('http://localhost', {
        method: 'POST', headers: {Authorization: 'Bearer user-session'},
        body: JSON.stringify(payload),
      }))
      if (invalid.status !== 400) throw Error('Invalid input must be rejected')
    }
    for (const token of ['', 'Bearer anon-key', 'Bearer expired-session']) {
      const unauthorized = await handler(new Request('http://localhost', {
        method: 'POST', headers: {Authorization: token},
        body: JSON.stringify({action: 'expense_parse', text: 'Lunch 10rb',
          category_codes: ['expense:basic:food']}),
      }))
      if (unauthorized.status !== 401) throw Error('A user session is required')
    }
    if (paidRequests !== 1) throw Error('Unauthenticated input reached paid inference')
  } finally {
    globalThis.fetch = originalFetch
    Object.defineProperty(Deno.env, 'get', {value: originalEnvGet})
  }
})
