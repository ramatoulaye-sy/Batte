-- Script pour ajouter des collecteurs de test dans Supabase
-- Utilise la structure existante de la table collectors
-- Executer dans Supabase SQL Editor

INSERT INTO public.collectors (
  user_id,
  business_name,
  license_number,
  vehicle_info,
  service_area_radius,
  rating,
  total_collections,
  total_earnings,
  is_available,
  current_location_lat,
  current_location_lng
)
VALUES 
  (
    NULL,
    'Recyclage Mamadou Diallo',
    'RC-GN-2024-001',
    'Camion Mercedes - Immatriculation: GN-123-ABC',
    10,
    4.8,
    156,
    2500000,
    true,
    9.5092,
    -13.7122
  ),
  (
    NULL,
    'Eco-Collecte Fatoumata',
    'RC-GN-2024-002',
    'Camionnette Toyota - GN-456-DEF',
    15,
    4.5,
    98,
    1800000,
    true,
    9.5370,
    -13.6760
  ),
  (
    NULL,
    'Batte Pro - Ibrahima Sow',
    'RC-GN-2024-003',
    'Tricycle electrique - GN-789-GHI',
    8,
    5.0,
    220,
    3200000,
    true,
    9.5780,
    -13.6480
  ),
  (
    NULL,
    'Dechets Verts Aissatou',
    'RC-GN-2024-004',
    'Camion Isuzu - GN-012-JKL',
    12,
    3.8,
    65,
    1200000,
    false,
    9.5500,
    -13.6800
  ),
  (
    NULL,
    'RecupAction Kourouma',
    'RC-GN-2024-005',
    'Moto avec remorque - GN-345-MNO',
    6,
    4.2,
    112,
    1950000,
    true,
    9.5650,
    -13.6200
  );

-- Verification
SELECT 
  business_name,
  license_number,
  rating,
  total_collections,
  is_available
FROM public.collectors 
ORDER BY rating DESC;
