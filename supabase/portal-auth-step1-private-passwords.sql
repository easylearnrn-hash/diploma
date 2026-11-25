-- STEP 1 of 2 (additive, safe to run any time, safe to re-run): private credential storage + backfill.
-- Nothing the pages read or write is changed by this file.
--
--   supabase db query --linked -f supabase/portal-auth-step1-private-passwords.sql
--
-- application_secrets holds, per application, everything that lets someone sign in as that student:
--   password_hash   SHA-256 hash the student portal compares against (same value the pages used)
--   plain_password  the password in clear text (admins view/e-mail it; kept only here, never readable with the public key)
--   latest_password payload.latestCredentials.password (the "latest credentials" card in admin-applications)
--   extra           every other secret that used to sit inside applications.payload (kept so nothing is lost / can be rolled back)
-- Only the server (service role: the admin-auth / portal-auth Edge Functions) can read this table.

create table if not exists public.application_secrets (
  application_id  uuid primary key,
  password_hash   text,
  plain_password  text,
  latest_password text,
  extra           jsonb not null default '{}'::jsonb,
  source          text  not null default 'backfill',   -- 'backfill' (copied from applications) or 'server' (written by an Edge Function)
  updated_at      timestamptz not null default now()
);

alter table public.application_secrets enable row level security;
revoke all on public.application_secrets from anon, authenticated;

-- Every place inside applications.payload where a password or password hash has been stored (dot-separated paths)
create or replace function public.app_secret_paths() returns text[]
language sql immutable as $$
  select array[
    'passwordHash', 'password_hash',
    'credentials.password', 'credentials.password_hash', 'credentials.passwordHash',
    'latestCredentials.password', 'credentialsSnapshot.password',
    'studentPortal.password', 'studentPortal.passwordHash',
    'studentPortal.credentials.passwordHash', 'studentPortal.credentials.password',
    'studentCredentials.passwordHash', 'studentCredentials.password',
    'portalCredentials.passwordHash', 'portalCredentials.password',
    'applicationCredentials.passwordHash', 'applicationCredentials.password'
  ];
$$;

-- payload without any secret
create or replace function public.app_payload_strip(p jsonb) returns jsonb
language plpgsql immutable as $$
declare
  one text;
  result jsonb := p;
begin
  if p is null or jsonb_typeof(p) <> 'object' then return p; end if;
  foreach one in array public.app_secret_paths() loop
    result := result #- string_to_array(one, '.');
  end loop;
  return result;
end $$;

-- the secrets found in a payload, as { "credentials.password": "...", ... }
create or replace function public.app_payload_extra(p jsonb) returns jsonb
language plpgsql immutable as $$
declare
  one text;
  v jsonb;
  result jsonb := '{}'::jsonb;
begin
  if p is null or jsonb_typeof(p) <> 'object' then return result; end if;
  foreach one in array public.app_secret_paths() loop
    v := p #> string_to_array(one, '.');
    if v is not null and jsonb_typeof(v) = 'string' and coalesce(v #>> '{}', '') <> '' then
      result := result || jsonb_build_object(one, v);
    end if;
  end loop;
  return result;
end $$;

-- The hash the student pages compare against: the column first, then the payload spots login.html / Videocall.html looked at
create or replace function public.app_effective_hash(col_hash text, p jsonb) returns text
language sql immutable as $$
  select nullif(coalesce(
    nullif(col_hash, ''),
    nullif(p->>'passwordHash', ''),
    nullif(p->>'password_hash', ''),
    nullif(p #>> '{studentPortal,passwordHash}', ''),
    nullif(p #>> '{studentPortal,credentials,passwordHash}', ''),
    nullif(p #>> '{studentCredentials,passwordHash}', ''),
    nullif(p #>> '{portalCredentials,passwordHash}', ''),
    nullif(p #>> '{credentials,passwordHash}', ''),
    nullif(p #>> '{applicationCredentials,passwordHash}', ''),
    nullif(p #>> '{credentials,password_hash}', '')
  ), '');
$$;

-- Backfill. Rows already written by the server are never overwritten.
insert into public.application_secrets (application_id, password_hash, plain_password, latest_password, extra, source)
select a.id,
       public.app_effective_hash(a.password_hash, a.payload),
       nullif(a.plain_password, ''),
       nullif(a.payload #>> '{latestCredentials,password}', ''),
       public.app_payload_extra(a.payload),
       'backfill'
from public.applications a
on conflict (application_id) do update
   set password_hash   = coalesce(excluded.password_hash, public.application_secrets.password_hash),
       plain_password  = coalesce(excluded.plain_password, public.application_secrets.plain_password),
       latest_password = coalesce(excluded.latest_password, public.application_secrets.latest_password),
       extra           = public.application_secrets.extra || excluded.extra,
       updated_at      = now()
   where public.application_secrets.source = 'backfill';

-- Trigger functions (inert until portal-auth-step2-lock.sql attaches them to applications).
-- They run as the table owner so the secrets table never needs a grant for the public roles. Who is calling is read from the
-- verified JWT role: anon / authenticated = a browser; anything else (service_role, SQL editor) = the server.
create or replace function public.applications_guard_secrets() returns trigger
language plpgsql security definer set search_path = public as $$
declare
  caller text := coalesce(nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role', '');
  restricted boolean := caller in ('anon', 'authenticated');
  v_hash text := public.app_effective_hash(NEW.password_hash, NEW.payload);
  v_plain text := nullif(NEW.plain_password, '');
  v_latest text := nullif(NEW.payload #>> '{latestCredentials,password}', '');
  v_extra jsonb := public.app_payload_extra(NEW.payload);
begin
  if v_hash is not null or v_plain is not null or v_latest is not null or v_extra <> '{}'::jsonb then
    if TG_OP = 'INSERT' and restricted then
      -- a browser may create the secrets of a NEW application (the admission form), never replace existing ones
      insert into public.application_secrets (application_id, password_hash, plain_password, latest_password, extra, source)
      values (NEW.id, v_hash, v_plain, v_latest, v_extra, 'trigger')
      on conflict (application_id) do nothing;
    elsif not restricted then
      insert into public.application_secrets (application_id, password_hash, plain_password, latest_password, extra, source)
      values (NEW.id, v_hash, v_plain, v_latest, v_extra, 'server')
      on conflict (application_id) do update
        set password_hash   = coalesce(excluded.password_hash, public.application_secrets.password_hash),
            plain_password  = coalesce(excluded.plain_password, public.application_secrets.plain_password),
            latest_password = coalesce(excluded.latest_password, public.application_secrets.latest_password),
            extra           = public.application_secrets.extra || excluded.extra,
            source          = 'server',
            updated_at      = now();
    end if;
    -- an UPDATE from a browser that tries to change a password is ignored
  end if;
  NEW.password_hash := null;
  NEW.plain_password := null;
  NEW.payload := public.app_payload_strip(NEW.payload);
  return NEW;
end $$;

create or replace function public.applications_drop_secrets() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  delete from public.application_secrets where application_id = OLD.id;
  return OLD;
end $$;

revoke all on function public.applications_guard_secrets() from public, anon, authenticated;
revoke all on function public.applications_drop_secrets() from public, anon, authenticated;
