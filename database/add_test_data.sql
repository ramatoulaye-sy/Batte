-- =====================================================
-- Script de Données de Test pour Battè
-- =====================================================
-- Ce script ajoute des données fictives pour tester :
-- - Les graphiques de gains hebdomadaires
-- - Le système de niveaux
-- - Les transactions
-- - L'historique de recyclage
-- =====================================================

-- ⚠️ IMPORTANT : Remplace 'TON_USER_ID' par ton vrai ID utilisateur
-- Pour trouver ton ID, exécute :
-- SELECT id, email FROM auth.users;

-- =====================================================
-- 1. Ajouter du solde et des points à ton compte
-- =====================================================
UPDATE public.users
SET 
  balance = 150000,  -- 150 000 GNF
  eco_score = 850,   -- 850 points (Niveau Silver)
  total_weight = 25.5,  -- 25.5 kg recyclés
  updated_at = NOW()
WHERE email = 'TON_EMAIL@batte.com';  -- ⚠️ REMPLACE PAR TON EMAIL

-- =====================================================
-- 2. Ajouter des transactions de recyclage (7 derniers jours)
-- =====================================================

-- Lundi (il y a 6 jours) : Recyclage de plastique
INSERT INTO public.transactions (user_id, amount, type, description, status, date)
SELECT 
  id, 
  15000, 
  'recycling', 
  'Recyclage de plastic - 15.0 kg',
  'completed',
  NOW() - INTERVAL '6 days'
FROM public.users
WHERE email = 'TON_EMAIL@batte.com';  -- ⚠️ REMPLACE PAR TON EMAIL

-- Mardi (il y a 5 jours) : Recyclage de papier
INSERT INTO public.transactions (user_id, amount, type, description, status, date)
SELECT 
  id, 
  8000, 
  'recycling', 
  'Recyclage de paper - 8.0 kg',
  'completed',
  NOW() - INTERVAL '5 days'
FROM public.users
WHERE email = 'TON_EMAIL@batte.com';  -- ⚠️ REMPLACE PAR TON EMAIL

-- Mercredi (il y a 4 jours) : Bonus de fidélité
INSERT INTO public.transactions (user_id, amount, type, description, status, date)
SELECT 
  id, 
  5000, 
  'reward', 
  'Bonus de fidélité',
  'completed',
  NOW() - INTERVAL '4 days'
FROM public.users
WHERE email = 'TON_EMAIL@batte.com';  -- ⚠️ REMPLACE PAR TON EMAIL

-- Jeudi (il y a 3 jours) : Recyclage de métal
INSERT INTO public.transactions (user_id, amount, type, description, status, date)
SELECT 
  id, 
  12000, 
  'recycling', 
  'Recyclage de metal - 12.0 kg',
  'completed',
  NOW() - INTERVAL '3 days'
FROM public.users
WHERE email = 'TON_EMAIL@batte.com';  -- ⚠️ REMPLACE PAR TON EMAIL

-- Vendredi (il y a 2 jours) : Recyclage de verre
INSERT INTO public.transactions (user_id, amount, type, description, status, date)
SELECT 
  id, 
  6000, 
  'recycling', 
  'Recyclage de glass - 6.0 kg',
  'completed',
  NOW() - INTERVAL '2 days'
FROM public.users
WHERE email = 'TON_EMAIL@batte.com';  -- ⚠️ REMPLACE PAR TON EMAIL

-- Samedi (il y a 1 jour) : Retrait
INSERT INTO public.transactions (user_id, amount, type, description, status, date)
SELECT 
  id, 
  20000, 
  'withdrawal', 
  'Retrait de gains',
  'completed',
  NOW() - INTERVAL '1 day'
FROM public.users
WHERE email = 'TON_EMAIL@batte.com';  -- ⚠️ REMPLACE PAR TON EMAIL

-- Dimanche (aujourd'hui) : Recyclage de plastique
INSERT INTO public.transactions (user_id, amount, type, description, status, date)
SELECT 
  id, 
  10000, 
  'recycling', 
  'Recyclage de plastic - 10.0 kg',
  'completed',
  NOW()
FROM public.users
WHERE email = 'TON_EMAIL@batte.com';  -- ⚠️ REMPLACE PAR TON EMAIL

-- =====================================================
-- 3. Vérifier les données ajoutées
-- =====================================================

-- Voir les transactions ajoutées
SELECT 
  type,
  amount,
  description,
  DATE(date) as jour,
  status
FROM public.transactions
WHERE user_id = (SELECT id FROM public.users WHERE email = 'TON_EMAIL@batte.com')  -- ⚠️ REMPLACE
ORDER BY date DESC;

-- Voir le profil mis à jour
SELECT 
  email,
  name,
  balance,
  eco_score,
  total_weight
FROM public.users
WHERE email = 'TON_EMAIL@batte.com';  -- ⚠️ REMPLACE

-- =====================================================
-- RÉSULTAT ATTENDU DANS L'APP
-- =====================================================
-- 
-- Écran Home :
-- ✅ Solde : 150 000 GNF
-- ✅ Badge : 🥈 Silver (850 pts)
-- ✅ Graphique : 7 jours avec courbe visible
-- ✅ Activité récente : 7 transactions affichées
-- ✅ Poids recyclé : 25.5 kg
-- ✅ Barre de progression : 85% vers Gold (1000 pts)
-- 
-- =====================================================

