SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;
COMMENT ON SCHEMA "public" IS 'standard public schema';
CREATE EXTENSION IF NOT EXISTS "pg_cron" WITH SCHEMA "public";
CREATE EXTENSION IF NOT EXISTS "pg_net" WITH SCHEMA "extensions";
CREATE EXTENSION IF NOT EXISTS "pgsodium" WITH SCHEMA "pgsodium";
CREATE EXTENSION IF NOT EXISTS "http" WITH SCHEMA "extensions";
CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";
CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";
CREATE EXTENSION IF NOT EXISTS "pgjwt" WITH SCHEMA "extensions";
CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";
CREATE OR REPLACE FUNCTION "public"."get_ihsg"() RETURNS TABLE("cf_code" "json", "cf_name" "json", "cf_last" "json", "cf_netchng" "json", "pctchng" "json")
    LANGUAGE "plpgsql"
    AS $$
BEGIN

RETURN QUERY
  SELECT
    content::json->'data'->0->'CODE' AS CF_CODE,
    content::json->'data'->0->'NAME' AS CF_NAME,
    content::json->'data'->0->'CF_LAST' AS CF_LAST,
    content::json->'data'->0->'CF_NETCHNG' AS CF_NETCHNG,
    content::json->'data'->0->'PCTCHNG' AS PCTCHNG
FROM
    http(
        (
            'POST',
            'https://www.cnbcindonesia.com/market-data/api/getMajorIndexes',
            ARRAY[
                http_header(
                    'accept',
                    'application/json'
                ),
                http_header(
                    'authorization',
                    'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJrZXkiOiJrMXQ0SGFydXNCaXM0IiwidGltZSI6MTUyMzkzMTMzMCwic2FsdCI6ImV5SjBlWEFpT2lKS1YxUWlMQ0poYkdjaU9pSklVekkxTmlKOS5NVFV5TXprek1UTXpNQS42MG5ZQ0oyX2hsRzlDTmxOR1dQcmVOMV8weHgwMW84Tzc4V3VyVXYtUTBRIn0.WAcM1Wska3QulFqRxvdA3Lk6tKQ9YdPZIkWEvArbGxA'
                )
            ],
            '',
            ''
        )::http_request
    ) AS response;
END;
$$;
ALTER FUNCTION "public"."get_ihsg"() OWNER TO "postgres";
CREATE OR REPLACE FUNCTION "public"."get_pintu"() RETURNS TABLE("api" character varying, "response" character varying)
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    RETURN QUERY
    -- HTTP request pertama
    WITH request1 AS (
        SELECT
            content
        FROM
            http(
                (
                    'GET',
                    'https://api.pintu.co.id/v2/wallet/supportedCurrencies',
                    null,
                    '',
                    ''
                )::http_request
            ) AS response
    )

    -- HTTP request kedua
    , request2 AS (
        SELECT
            content
        FROM
            http(
                (
                    'GET',
                    'https://api.pintu.co.id/v2/trade/price-changes',
                    null,
                    '',
                    ''
                )::http_request
            ) AS response
    )

    SELECT
        'supportedCurrencies'::VARCHAR AS api,
        r1.content::VARCHAR AS response
    FROM
        request1 r1
    UNION ALL
    SELECT
        'price-changes'::VARCHAR AS api,
        r2.content::VARCHAR AS response
    FROM
        request2 r2;
  END;
$$;
ALTER FUNCTION "public"."get_pintu"() OWNER TO "postgres";
CREATE OR REPLACE FUNCTION "public"."get_spender_day"("userid" "uuid", "periode" character varying) RETURNS TABLE("date" character varying, "total" numeric)
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        e.date::VARCHAR, 
        SUM(e.amount)::DECIMAL AS total
    FROM 
        expense e
    WHERE
    	e.user_id = userId 
    	AND
        e.date LIKE periode || '%'
    GROUP BY 
        e.date
    HAVING SUM(e.amount) > 100000
    ORDER BY 
        e.date DESC;
END;
$$;
ALTER FUNCTION "public"."get_spender_day"("userid" "uuid", "periode" character varying) OWNER TO "postgres";
CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  insert into public.profiles (id, full_name, avatar_url)
  values (new.id, new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'avatar_url');
  return new;
end;
$$;
ALTER FUNCTION "public"."handle_new_user"() OWNER TO "postgres";
CREATE OR REPLACE FUNCTION "public"."javlib_bycode"("code" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  url TEXT;
  res TEXT;
BEGIN
  url := 'https://www.javlibrary.com/en/vl_searchbyid.php?keyword=' || code;
  res := (SELECT content::TEXT FROM http_get(url));
  RETURN res;

END;
$$;
ALTER FUNCTION "public"."javlib_bycode"("code" "text") OWNER TO "postgres";
CREATE OR REPLACE FUNCTION "public"."javlib_byid"("id" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  url TEXT;
  res TEXT;
BEGIN
  url := 'https://www.javlibrary.com/en/?v=' || id;

  res := (SELECT 
             content::TEXT
          FROM http_get(url));

  RETURN res;

END;
$$;
ALTER FUNCTION "public"."javlib_byid"("id" "text") OWNER TO "postgres";
CREATE OR REPLACE FUNCTION "public"."sum_all_month"("userid" "uuid", "periode" integer) RETURNS TABLE("period" character varying, "total" integer)
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    i INT := 1;
BEGIN
    FOR i IN 1..12 LOOP
        period := TO_CHAR(periode, 'FM0000') || '-' || LPAD(i::TEXT, 2, '0');
        RETURN QUERY
            SELECT 
                period,
                COALESCE(SUM(amount), 0)::INT as total 
            FROM expense 
            WHERE 
            		user_id = userId 
              AND
            		date LIKE '%' || period || '%'
              
            ;
    END LOOP;
END;
$$;
ALTER FUNCTION "public"."sum_all_month"("userid" "uuid", "periode" integer) OWNER TO "postgres";
CREATE OR REPLACE FUNCTION "public"."sum_by_category"("userid" "uuid", "periode" character varying) RETURNS TABLE("period" character varying, "category_id" character varying, "category_name" character varying, "category_color" character varying, "category_icon" character varying, "max_budget" numeric, "total" numeric, "use_percentage" integer, "remaining_budget" numeric)
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        periode::varchar,
        c.id::varchar,
        c.name::varchar,
        c.color::varchar,
        c.icon::varchar,
        c.max_budget::numeric,
        COALESCE(SUM(e.amount), 0)::numeric,
        CASE 
            WHEN c.max_budget IS NOT NULL AND c.max_budget > 0 THEN CAST(COALESCE(SUM(e.amount), 0) / c.max_budget * 100 AS INTEGER) 
            ELSE NULL 
        END::integer,
        CASE 
            WHEN c.max_budget IS NOT NULL THEN c.max_budget - COALESCE(SUM(e.amount), 0) 
            ELSE NULL 
        END::numeric
    FROM category c
    LEFT JOIN expense e ON e.category_name = c.name AND e.date LIKE '%' || periode || '%' 
    WHERE c.user_id = userid
    GROUP BY c.name, c.max_budget  
    ORDER BY c.max_budget DESC NULLS LAST, c.name;
END;
$$;
ALTER FUNCTION "public"."sum_by_category"("userid" "uuid", "periode" character varying) OWNER TO "postgres";
CREATE OR REPLACE FUNCTION "public"."sum_note_times"("userid" "uuid", "periode" character varying) RETURNS TABLE("period" character varying, "note" character varying, "times" integer, "total" numeric)
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    RETURN QUERY
      SELECT
      	periode::VARCHAR,
        e.note::VARCHAR, 
        COUNT(e.note)::INTEGER AS times, 
        SUM(e.amount)::DECIMAL AS total
      FROM expense e
      WHERE 
      		e.user_id = userId
      	AND
      		e.date LIKE '%' || periode || '%'
      GROUP BY e.note
      ORDER BY times DESC;
END;
$$;
ALTER FUNCTION "public"."sum_note_times"("userid" "uuid", "periode" character varying) OWNER TO "postgres";
CREATE OR REPLACE FUNCTION "public"."truncate_error_log"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    DELETE FROM error_log WHERE created_at < now() - interval '3 months';
    RETURN NEW;
END;
$$;
ALTER FUNCTION "public"."truncate_error_log"() OWNER TO "postgres";
SET default_tablespace = '';
SET default_table_access_method = "heap";
CREATE TABLE IF NOT EXISTS "public"."autocomplete" (
    "created_at" timestamp with time zone DEFAULT "now"(),
    "note" "text" NOT NULL,
    "user_id" "uuid",
    "category_name" "text",
    "amount" "text" DEFAULT ''::"text",
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL
);
ALTER TABLE "public"."autocomplete" OWNER TO "postgres";
CREATE TABLE IF NOT EXISTS "public"."category" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "name" "text" NOT NULL,
    "user_id" "uuid" DEFAULT "auth"."uid"(),
    "color" "text",
    "icon" "text" DEFAULT 'code=59513&family=LineAwesomeIcons&pack=flutter_iconpicker_plus'::"text",
    "max_budget" bigint,
    "is_protect" boolean DEFAULT false
);
ALTER TABLE "public"."category" OWNER TO "postgres";
COMMENT ON COLUMN "public"."category"."is_protect" IS 'show for all user?';
CREATE TABLE IF NOT EXISTS "public"."error_log" (
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "user_email" "text",
    "page" "text",
    "action" "text",
    "stack" "text",
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL
);
ALTER TABLE "public"."error_log" OWNER TO "postgres";
CREATE TABLE IF NOT EXISTS "public"."expense" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "category_name" "text" DEFAULT 'Others'::"text",
    "note" "text",
    "amount" numeric DEFAULT '222'::numeric NOT NULL,
    "date" "text" NOT NULL,
    "user_id" "uuid",
    "detail" "text" DEFAULT ''::"text"
);
ALTER TABLE "public"."expense" OWNER TO "postgres";
CREATE TABLE IF NOT EXISTS "public"."profiles" (
    "id" "uuid" NOT NULL,
    "updated_at" timestamp with time zone,
    "username" "text",
    "full_name" "text",
    "avatar_url" "text",
    "website" "text",
    "dob" "text",
    CONSTRAINT "username_length" CHECK (("char_length"("username") >= 3))
);
ALTER TABLE "public"."profiles" OWNER TO "postgres";
ALTER TABLE ONLY "public"."autocomplete"
    ADD CONSTRAINT "autocomplete_id_key" UNIQUE ("id");
ALTER TABLE ONLY "public"."autocomplete"
    ADD CONSTRAINT "autocomplete_pkey" PRIMARY KEY ("note");
ALTER TABLE ONLY "public"."category"
    ADD CONSTRAINT "category_pkey" PRIMARY KEY ("name");
ALTER TABLE ONLY "public"."error_log"
    ADD CONSTRAINT "error_log_pkey" PRIMARY KEY ("id");
ALTER TABLE ONLY "public"."expense"
    ADD CONSTRAINT "expanse_pkey" PRIMARY KEY ("id");
ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_pkey" PRIMARY KEY ("id");
ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_username_key" UNIQUE ("username");
CREATE OR REPLACE TRIGGER "truncate_error_log_trigger" AFTER INSERT OR DELETE OR UPDATE ON "public"."error_log" FOR EACH ROW EXECUTE FUNCTION "public"."truncate_error_log"();
ALTER TABLE ONLY "public"."autocomplete"
    ADD CONSTRAINT "autocomplete_category_name_fkey" FOREIGN KEY ("category_name") REFERENCES "public"."category"("name") ON UPDATE CASCADE ON DELETE SET DEFAULT;
ALTER TABLE ONLY "public"."autocomplete"
    ADD CONSTRAINT "autocomplete_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id");
ALTER TABLE ONLY "public"."category"
    ADD CONSTRAINT "category_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id");
ALTER TABLE ONLY "public"."expense"
    ADD CONSTRAINT "expense_category_name_fkey" FOREIGN KEY ("category_name") REFERENCES "public"."category"("name") ON UPDATE CASCADE ON DELETE SET DEFAULT;
ALTER TABLE ONLY "public"."expense"
    ADD CONSTRAINT "expense_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id");
ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;
CREATE POLICY "Enable crud for authenticated users only" ON "public"."autocomplete" TO "authenticated" USING (true) WITH CHECK (true);
CREATE POLICY "Enable crud for authenticated users only" ON "public"."category" TO "authenticated" USING (true) WITH CHECK (true);
CREATE POLICY "Enable crud for authenticated users only" ON "public"."expense" TO "authenticated" USING (true) WITH CHECK (true);
CREATE POLICY "Public profiles are viewable by everyone." ON "public"."profiles" FOR SELECT USING (true);
CREATE POLICY "Users can insert their own profile." ON "public"."profiles" FOR INSERT WITH CHECK (("auth"."uid"() = "id"));
CREATE POLICY "Users can update own profile." ON "public"."profiles" FOR UPDATE USING (("auth"."uid"() = "id"));
ALTER TABLE "public"."autocomplete" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."category" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."expense" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."profiles" ENABLE ROW LEVEL SECURITY;
ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";
ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."autocomplete";
ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."category";
ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."expense";
GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";
SET SESSION AUTHORIZATION "postgres";
RESET SESSION AUTHORIZATION;
SET SESSION AUTHORIZATION "postgres";
RESET SESSION AUTHORIZATION;
SET SESSION AUTHORIZATION "postgres";
RESET SESSION AUTHORIZATION;
SET SESSION AUTHORIZATION "postgres";
RESET SESSION AUTHORIZATION;
SET SESSION AUTHORIZATION "postgres";
RESET SESSION AUTHORIZATION;
SET SESSION AUTHORIZATION "postgres";
RESET SESSION AUTHORIZATION;
SET SESSION AUTHORIZATION "postgres";
RESET SESSION AUTHORIZATION;
SET SESSION AUTHORIZATION "postgres";
RESET SESSION AUTHORIZATION;
SET SESSION AUTHORIZATION "postgres";
RESET SESSION AUTHORIZATION;
SET SESSION AUTHORIZATION "postgres";
RESET SESSION AUTHORIZATION;
SET SESSION AUTHORIZATION "postgres";
RESET SESSION AUTHORIZATION;
SET SESSION AUTHORIZATION "postgres";
RESET SESSION AUTHORIZATION;
SET SESSION AUTHORIZATION "postgres";
RESET SESSION AUTHORIZATION;
SET SESSION AUTHORIZATION "postgres";
RESET SESSION AUTHORIZATION;
SET SESSION AUTHORIZATION "postgres";
RESET SESSION AUTHORIZATION;
SET SESSION AUTHORIZATION "postgres";
RESET SESSION AUTHORIZATION;
GRANT ALL ON FUNCTION "public"."get_ihsg"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_ihsg"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_ihsg"() TO "service_role";
GRANT ALL ON FUNCTION "public"."get_pintu"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_pintu"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_pintu"() TO "service_role";
GRANT ALL ON FUNCTION "public"."get_spender_day"("userid" "uuid", "periode" character varying) TO "anon";
GRANT ALL ON FUNCTION "public"."get_spender_day"("userid" "uuid", "periode" character varying) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_spender_day"("userid" "uuid", "periode" character varying) TO "service_role";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "service_role";
GRANT ALL ON FUNCTION "public"."javlib_bycode"("code" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."javlib_bycode"("code" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."javlib_bycode"("code" "text") TO "service_role";
GRANT ALL ON FUNCTION "public"."javlib_byid"("id" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."javlib_byid"("id" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."javlib_byid"("id" "text") TO "service_role";
GRANT ALL ON FUNCTION "public"."sum_all_month"("userid" "uuid", "periode" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."sum_all_month"("userid" "uuid", "periode" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."sum_all_month"("userid" "uuid", "periode" integer) TO "service_role";
GRANT ALL ON FUNCTION "public"."sum_by_category"("userid" "uuid", "periode" character varying) TO "anon";
GRANT ALL ON FUNCTION "public"."sum_by_category"("userid" "uuid", "periode" character varying) TO "authenticated";
GRANT ALL ON FUNCTION "public"."sum_by_category"("userid" "uuid", "periode" character varying) TO "service_role";
GRANT ALL ON FUNCTION "public"."sum_note_times"("userid" "uuid", "periode" character varying) TO "anon";
GRANT ALL ON FUNCTION "public"."sum_note_times"("userid" "uuid", "periode" character varying) TO "authenticated";
GRANT ALL ON FUNCTION "public"."sum_note_times"("userid" "uuid", "periode" character varying) TO "service_role";
GRANT ALL ON FUNCTION "public"."truncate_error_log"() TO "anon";
GRANT ALL ON FUNCTION "public"."truncate_error_log"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."truncate_error_log"() TO "service_role";
SET SESSION AUTHORIZATION "postgres";
RESET SESSION AUTHORIZATION;
SET SESSION AUTHORIZATION "postgres";
RESET SESSION AUTHORIZATION;
SET SESSION AUTHORIZATION "postgres";
RESET SESSION AUTHORIZATION;
SET SESSION AUTHORIZATION "postgres";
RESET SESSION AUTHORIZATION;
SET SESSION AUTHORIZATION "postgres";
RESET SESSION AUTHORIZATION;
SET SESSION AUTHORIZATION "postgres";
RESET SESSION AUTHORIZATION;
SET SESSION AUTHORIZATION "postgres";
RESET SESSION AUTHORIZATION;
SET SESSION AUTHORIZATION "postgres";
RESET SESSION AUTHORIZATION;
GRANT ALL ON TABLE "public"."autocomplete" TO "anon";
GRANT ALL ON TABLE "public"."autocomplete" TO "authenticated";
GRANT ALL ON TABLE "public"."autocomplete" TO "service_role";
GRANT ALL ON TABLE "public"."category" TO "anon";
GRANT ALL ON TABLE "public"."category" TO "authenticated";
GRANT ALL ON TABLE "public"."category" TO "service_role";
GRANT ALL ON TABLE "public"."error_log" TO "anon";
GRANT ALL ON TABLE "public"."error_log" TO "authenticated";
GRANT ALL ON TABLE "public"."error_log" TO "service_role";
GRANT ALL ON TABLE "public"."expense" TO "anon";
GRANT ALL ON TABLE "public"."expense" TO "authenticated";
GRANT ALL ON TABLE "public"."expense" TO "service_role";
GRANT ALL ON TABLE "public"."profiles" TO "anon";
GRANT ALL ON TABLE "public"."profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."profiles" TO "service_role";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";
RESET ALL;
