-- Mise a jour de la fonction get_collectors
-- Executer dans Supabase SQL Editor

DROP FUNCTION IF EXISTS public.get_collectors();

CREATE OR REPLACE FUNCTION public.get_collectors()
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_result JSON;
BEGIN
  SELECT COALESCE(json_agg(collector_data), '[]'::json)
  INTO v_result
  FROM (
    SELECT json_build_object(
      'id', c.id,
      'name', c.business_name,
      'location', 'Conakry',
      'phone', COALESCE(u.phone, '+224 620 00 00 00'),
      'latitude', c.current_location_lat,
      'longitude', c.current_location_lng,
      'availability', c.is_available,
      'rating', COALESCE(c.rating, 0),
      'distance', NULL,
      'vehicle_info', c.vehicle_info,
      'license_number', c.license_number,
      'total_collections', COALESCE(c.total_collections, 0),
      'service_area_radius', c.service_area_radius
    ) as collector_data
    FROM public.collectors c
    LEFT JOIN public.users u ON c.user_id = u.id
    WHERE c.is_available IS NOT NULL
    ORDER BY c.rating DESC NULLS LAST, c.total_collections DESC NULLS LAST
  ) subquery;

  RETURN v_result;
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_collectors() TO anon, authenticated;

-- Test: devrait retourner les 4 collecteurs disponibles
SELECT public.get_collectors();
