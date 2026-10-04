create or replace function public.classement_mois(p_mois text) returns table(commercial_id uuid,commercial text,dossiers bigint,mrr numeric,arr numeric,prime numeric,rang bigint) language sql security definer set search_path=public as $$
with stats as(
  select c.id commercial_id,c.nom commercial,count(d.id)::bigint dossiers,coalesce(sum(d.montant_mensuel),0)::numeric mrr
  from commerciaux c
  join dossiers d on d.commercial_id=c.id and d.mois=p_mois and coalesce(d.statut,'actif')='actif'
  group by c.id,c.nom
), ranked as(select *,dense_rank() over(order by dossiers desc,mrr desc,commercial asc)::bigint rang from stats), cfg as(select * from challenges_mois where mois=p_mois), team as(select coalesce(sum(dossiers),0) n from stats)
select r.commercial_id,r.commercial,r.dossiers,r.mrr,(r.mrr*12)::numeric arr,(coalesce((select max((p->>'prime')::numeric) from cfg,jsonb_array_elements(cfg.paliers)p where (p->>'seuil_dossiers')::int<=r.dossiers),0)+case when r.rang=1 and r.dossiers>=coalesce((select minimum_premier from cfg),0) then coalesce((select prime_premier from cfg),0) else 0 end+case when (select n from team)>=coalesce((select challenge_collectif_seuil from cfg),2147483647) then coalesce((select challenge_collectif_prime from cfg),0) else 0 end)::numeric prime,r.rang from ranked r order by r.rang,r.commercial;
$$;
revoke all on function public.classement_mois(text) from public;
grant execute on function public.classement_mois(text) to anon,authenticated;
