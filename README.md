# Challenge Rattrapage Churn

Application Limova de suivi du churn récupéré : dépôt temps réel, MRR/ARR, classement mensuel, primes et administration sécurisée.

## Stack
React + TypeScript + Vite + Tailwind, Supabase (Postgres/RLS/RPC/Edge Functions/Realtime). Aucun dossier client n'est lisible directement depuis le navigateur.

## 1. Supabase
Crée un projet Supabase puis lie le repo avec le CLI :

```bash
supabase login
supabase link --project-ref TON_PROJECT_REF
supabase db push
supabase functions deploy deposer-dossier
supabase functions deploy admin-login
supabase functions deploy admin-api
```

Configure ensuite les deux secrets serveur (ne jamais les mettre dans GitHub) :

```bash
supabase secrets set ADMIN_CODE="TON_CODE_ADMIN"
supabase secrets set ADMIN_JWT_SECRET="UNE_CLE_ALEATOIRE_TRES_LONGUE"
```

Le JWT admin maison est signé HMAC et expire après 12 h. Le login est limité à 5 échecs par IP hachée sur 15 minutes.

## 2. Frontend
Copie `.env.example` vers `.env.local` et renseigne uniquement les valeurs publiques :

```bash
VITE_SUPABASE_URL=...
VITE_SUPABASE_ANON_KEY=...
npm install
npm run dev
```

## Sécurité
- RLS activé sur toutes les tables.
- Le public ne peut lire que commerciaux actifs, offres actives et challenges.
- Les emails de dossiers ne sont jamais exposés par le RPC public.
- Les montants Essentiel/Pro/Charly+ sont recalculés côté Edge Function au dépôt puis figés.
- Les doublons email/mois sont enregistrés et signalés.
- Toutes les mutations admin passent par `admin-api` avec service role côté serveur.
- Le token admin est conservé uniquement dans `sessionStorage` comme prévu.
- Le dernier commercial public est mémorisé par cookie (pas de `localStorage`).

## Realtime
Après un dépôt réussi, le client diffuse uniquement le mois concerné sur le canal Broadcast `challenge-rattrapage`. Aucun email ni donnée client n'est diffusé.
