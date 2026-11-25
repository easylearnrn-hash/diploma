-- Undo portal-auth-step2-lock.sql: put every secret back where it was and re-open the columns.
-- (application_secrets is kept; it is not readable by browsers.)
--
--   supabase db query --linked -f supabase/portal-auth-rollback.sql

drop trigger if exists applications_guard_secrets on public.applications;
drop trigger if exists applications_drop_secrets on public.applications;

update public.applications a
   set password_hash  = s.password_hash,
       plain_password = s.plain_password
  from public.application_secrets s
 where s.application_id = a.id;

do $$
declare r record; k text; v jsonb; p jsonb;
begin
  for r in select a.id, a.payload as payload, s.extra, s.latest_password, s.password_hash
             from public.applications a join public.application_secrets s on s.application_id = a.id loop
    p := coalesce(r.payload, '{}'::jsonb);
    if jsonb_typeof(p) = 'object' then
      for k, v in select key, value from jsonb_each(r.extra) loop
        begin
          p := jsonb_set(p, string_to_array(k, '.'), v, true);
        exception when others then null;
        end;
      end loop;
      if r.latest_password is not null and p ? 'latestCredentials' and jsonb_typeof(p->'latestCredentials') = 'object' then
        p := jsonb_set(p, '{latestCredentials,password}', to_jsonb(r.latest_password), true);
      end if;
      if r.password_hash is not null and p ? 'passwordHash' then
        p := jsonb_set(p, '{passwordHash}', to_jsonb(r.password_hash), true);
      end if;
      update public.applications set payload = p where id = r.id;
    end if;
  end loop;
end $$;

alter table public.teachers alter column password_hash drop default;
grant all on public.teachers to anon, authenticated;

notify pgrst, 'reload schema';
