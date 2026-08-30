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
CREATE EXTENSION IF NOT EXISTS "http" WITH SCHEMA "extensions";
CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";
CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";
CREATE EXTENSION IF NOT EXISTS "pgjwt" WITH SCHEMA "extensions";
CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";
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
GRANT ALL ON FUNCTION "public"."get_spender_day"("userid" "uuid", "periode" character varying) TO "anon";
GRANT ALL ON FUNCTION "public"."get_spender_day"("userid" "uuid", "periode" character varying) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_spender_day"("userid" "uuid", "periode" character varying) TO "service_role";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "service_role";
GRANT ALL ON FUNCTION "public"."sum_all_month"("userid" "uuid", "periode" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."sum_all_month"("userid" "uuid", "periode" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."sum_all_month"("userid" "uuid", "periode" integer) TO "service_role";
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
