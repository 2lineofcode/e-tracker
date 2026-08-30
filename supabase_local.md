# Remote schema

```sh
supabase link --project-ref <project-ref>
supabase db pull
supabase migration up
```

# Copy remote data locally

Set `SUPABASE_DB_URL` in your shell without committing it, then run:

```sh
supabase db dump --db-url "$SUPABASE_DB_URL" -f backup.sql --data-only
supabase db reset
```

# Local services

```sh
supabase status
```

# Agnes proxy

Copy `supabase/functions/agent-proxy/.env.example` to `.env.local`, fill the
Agent credentials, then run locally:

```sh
supabase functions serve agent-proxy --env-file supabase/functions/agent-proxy/.env.local
```

Deploy the secret and function:

```sh
supabase secrets set --env-file supabase/functions/agent-proxy/.env.local
supabase functions deploy agent-proxy
```
