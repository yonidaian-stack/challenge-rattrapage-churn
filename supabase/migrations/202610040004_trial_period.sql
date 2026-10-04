alter table public.dossiers
  add column if not exists periode_essai boolean not null default false,
  add column if not exists jours_essai integer;

alter table public.dossiers drop constraint if exists dossiers_jours_essai_check;
alter table public.dossiers add constraint dossiers_jours_essai_check
  check ((periode_essai = false and jours_essai is null) or (periode_essai = true and jours_essai between 1 and 365));
