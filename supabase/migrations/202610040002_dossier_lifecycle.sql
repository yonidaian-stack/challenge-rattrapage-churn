alter table public.dossiers
  add column if not exists statut text not null default 'actif',
  add column if not exists motif_statut text,
  add column if not exists statut_updated_at timestamptz;

alter table public.dossiers drop constraint if exists dossiers_statut_check;
alter table public.dossiers add constraint dossiers_statut_check check (statut in ('actif','standby','annule'));
create index if not exists dossiers_mois_statut_idx on public.dossiers (mois, statut);
update public.dossiers set statut='actif' where statut is null;
