-- STEP 2 of 2: take every password out of anything the public key can read. Run ONLY after the pages and Edge Functions that
-- use portal-auth / admin-auth are published (see PORTAL-AUTH-SETUP.md). Roll back with supabase/portal-auth-rollback.sql.
--
--   supabase db query --linked -f supabase/portal-auth-step2-lock.sql

-- 1) applications: secrets move to application_secrets and are blanked in the row; browsers can no longer change them
-- (catch up with anything written since step 1; rows written by the server are left alone)
insert into public.application_secrets (application_id, password_hash, plain_password, latest_password, extra, source)
select a.id, public.app_effective_hash(a.password_hash, a.payload), nullif(a.plain_password, ''),
       nullif(a.payload #>> '{latestCredentials,password}', ''), public.app_payload_extra(a.payload), 'backfill'
from public.applications a
on conflict (application_id) do update
   set password_hash   = coalesce(excluded.password_hash, public.application_secrets.password_hash),
       plain_password  = coalesce(excluded.plain_password, public.application_secrets.plain_password),
       latest_password = coalesce(excluded.latest_password, public.application_secrets.latest_password),
       extra           = public.application_secrets.extra || excluded.extra,
       updated_at      = now()
   where public.application_secrets.source = 'backfill';

drop trigger if exists applications_guard_secrets on public.applications;
create trigger applications_guard_secrets
  before insert or update on public.applications
  for each row execute function public.applications_guard_secrets();

drop trigger if exists applications_drop_secrets on public.applications;
create trigger applications_drop_secrets
  after delete on public.applications
  for each row execute function public.applications_drop_secrets();

-- blank the existing rows (the trigger sees a privileged caller, keeps the server copy and strips the row)
update public.applications
   set password_hash = null, plain_password = null, payload = public.app_payload_strip(payload)
 where password_hash is not null or plain_password is not null or payload is distinct from public.app_payload_strip(payload);

-- 2) teachers: the password column is invisible and read-only for browsers; the Edge Functions (service role) manage it
do $$
declare cols text;
begin
  select string_agg(quote_ident(column_name), ', ' order by ordinal_position) into cols
    from information_schema.columns
   where table_schema = 'public' and table_name = 'teachers' and column_name <> 'password_hash';
  alter table public.teachers alter column password_hash set default '';
  revoke select, insert, update on public.teachers from anon, authenticated;
  execute format('grant select (%s) on public.teachers to anon, authenticated', cols);
  execute format('grant insert (%s) on public.teachers to anon, authenticated', cols);
  execute format('grant update (%s) on public.teachers to anon, authenticated', cols);
end $$;

notify pgrst, 'reload schema';
