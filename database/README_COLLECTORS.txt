SETUP COLLECTEURS - 3 ÉTAPES
================================

La table collectors existe déjà avec cette structure:
- business_name (nom du business)
- license_number (numéro de licence)
- vehicle_info (infos véhicule)
- current_location_lat/lng (coordonnées GPS)
- is_available (disponibilité)
- rating (note /5)

ÉTAPES À SUIVRE:
----------------

1. Exécute: database/update_get_collectors_function.sql
   → Crée la fonction RPC get_collectors()

2. Exécute: database/add_test_collectors.sql
   → Ajoute 5 collecteurs de test

3. Teste l'app !
   → Les collecteurs apparaîtront dans l'écran

TERMINÉ ✅

