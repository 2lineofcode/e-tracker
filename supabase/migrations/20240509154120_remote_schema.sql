CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION handle_new_user();
set check_function_bodies = off;
CREATE OR REPLACE FUNCTION storage.extension(name text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
_parts text[];
_filename text;
BEGIN
    select string_to_array(name, '/') into _parts;
    select _parts[array_length(_parts,1)] into _filename;
    -- @todo return the last part instead of 2
    return split_part(_filename, '.', 2);
END
$function$;
CREATE OR REPLACE FUNCTION storage.filename(name text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
_parts text[];
BEGIN
    select string_to_array(name, '/') into _parts;
    return _parts[array_length(_parts,1)];
END
$function$;
CREATE OR REPLACE FUNCTION storage.foldername(name text)
 RETURNS text[]
 LANGUAGE plpgsql
AS $function$
DECLARE
_parts text[];
BEGIN
    select string_to_array(name, '/') into _parts;
    return _parts[1:array_length(_parts,1)-1];
END
$function$;
create policy "User can ADD avatar"
on "storage"."objects"
as permissive
for insert
to authenticated
with check ((bucket_id = 'avatars'::text));
create policy "User can ADD backup"
on "storage"."objects"
as permissive
for insert
to authenticated
with check ((bucket_id = 'backup'::text));
create policy "User can DELETE backup"
on "storage"."objects"
as permissive
for delete
to authenticated
using ((bucket_id = 'backup'::text));
create policy "User can READ avatar"
on "storage"."objects"
as permissive
for select
to authenticated
using ((bucket_id = 'avatars'::text));
create policy "User can READ backup"
on "storage"."objects"
as permissive
for select
to authenticated
using ((bucket_id = 'backup'::text));
create policy "User can UPDATE avatar"
on "storage"."objects"
as permissive
for update
to authenticated
using ((bucket_id = 'avatars'::text));
create policy "User can UPDATE backup"
on "storage"."objects"
as permissive
for update
to authenticated
using ((bucket_id = 'backup'::text));
create policy "can read lottie"
on "storage"."objects"
as permissive
for select
to anon, authenticated, service_role
using ((bucket_id = 'lottie'::text));
