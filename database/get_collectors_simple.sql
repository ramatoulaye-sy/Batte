-- Version simple sans WHERE pour debug
-- Executer dans Supabase SQL Editor

DROP FUNCTION IF EXISTS public.get_collectors();

CREATE OR REPLACE FUNCTION public.get_collectors()
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN (
    SELECT COALESCE(
      json_agg(
        json_build_object(
          'id', id,
          'name', business_name,
          'location', 'Conakry',
          'phone', '+224 620 00 00 00',
          'latitude', current_location_lat,
          'longitude', current_location_lng,
          'availability', is_available,
          'rating', COALESCE(rating, 0),
          'distance', NULL,
          'vehicle_info', vehicle_info,
          'license_number', license_number,
          'total_collections', COALESCE(total_collections, 0),
          'service_area_radius', service_area_radius
        )
      ),
      '[]'::json
    )
    FROM public.collectors
    ORDER BY rating DESC NULLS LAST
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_collectors() TO anon, authenticated;

-- Test
SELECT public.get_collectors();

