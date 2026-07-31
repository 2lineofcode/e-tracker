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
