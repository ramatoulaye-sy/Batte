import 'package:flutter/material.dart';
import 'package:batte/core/app_theme.dart';
import 'package:batte/services/mock_auth_service.dart';
import 'package:batte/services/supabase_service.dart';
import 'package:batte/services/auth_service.dart';
import 'package:batte/core/routes.dart';
import 'package:batte/features/home/presentation/widgets/home_header.dart';
import 'package:batte/features/home/presentation/widgets/interactive_map.dart';
import 'package:batte/features/home/presentation/widgets/quick_actions.dart';
import 'package:batte/features/home/presentation/widgets/collector_list.dart';
import 'package:batte/features/home/presentation/widgets/bottom_navigation.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late double _currentBalance;
  late int _currentPoints;
  late double _monthlyWaste;
  bool _canSell = false;
  bool _isLocationActive = false;
  String _userName = 'Utilisateur';
  String? _avatarUrl;
  
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _setupAnimations();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final mockAuth = MockAuthService();
    final userStats = mockAuth.getUserStats();
    final supabase = SupabaseService.instance;
    final auth = AuthService.instance;

    setState(() {
      _currentBalance = userStats['balance'] ?? 0.0;
      _currentPoints = userStats['points'] ?? 0;
      _monthlyWaste = userStats['monthlyWaste'] ?? 0.0;
      _canSell = _monthlyWaste >= 1.0;
    });

    // Charger nom et avatar depuis Supabase si connecté
    if (supabase.isAuthenticated && supabase.currentUserId != null) {
      auth.getProfile(supabase.currentUserId!).then((profile) {
        if (!mounted || profile == null) return;
        setState(() {
          _userName = (profile['name'] as String?) ?? _userName;
          _avatarUrl = (profile['avatar_url'] as String?);
        });
      });
    }
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    if (_canSell) {
      _pulseController.repeat(reverse: true);
    }
  }

  

  void _activateLocation() {
    setState(() {
      _isLocationActive = true;
    });
    // Ici on activerait la géolocalisation
    _showLocationActiveDialog();
  }

  void _showLocationActiveDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.location_on,
              color: AppTheme.primaryColor,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text('Localisation Activée'),
          ],
        ),
        content: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppTheme.successColor,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Votre Bitmoji est maintenant visible sur la carte avec le message :',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.onBackgroundColor,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '"Salut je suis ${_getUserName()}, j\'ai ${_monthlyWaste}kg, venez acheter mes déchets!"',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: AppTheme.onPrimaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Parfait !',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  String _getUserName() {
    final mockAuth = MockAuthService();
    final currentUser = mockAuth.currentUser;
    
    if (currentUser != null) {
      return currentUser['name'] ?? 'Utilisateur';
    }
    
    // Fallback basé sur le poids
    if (_monthlyWaste >= 10) return 'Vicky';
    if (_monthlyWaste >= 5) return 'Sama';
    return 'Ana';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double mapHeight = (constraints.maxHeight * 0.28).clamp(160.0, 280.0);
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // En-tête avec solde et points
                  HomeHeader(
                    balance: _currentBalance,
                    points: _currentPoints,
                    monthlyWaste: _monthlyWaste,
                    canSell: _canSell,
                    onSellPressed: _canSell ? _activateLocation : null,
                    userName: _userName,
                    avatarUrl: _avatarUrl,
                  ),
                  const SizedBox(height: 8),
                  
                  // Carte interactive (hauteur réduite pour éviter l'overflow)
                  SizedBox(
                    height: mapHeight,
                    child: InteractiveMap(
                      isLocationActive: _isLocationActive,
                      userName: _getUserName(),
                      monthlyWaste: _monthlyWaste,
                      showRealCollectors: _isLocationActive, // Charger les vrais collecteurs quand la localisation est active
                      onCollectorSelected: _selectCollector,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Actions rapides
                  QuickActions(
                    canSell: _canSell,
                    onSellPressed: _canSell ? _activateLocation : null,
                  ),
                  
                  // Liste des collecteurs proches
                  if (_isLocationActive) ...[
                    const SizedBox(height: 4),
                    CollectorList(
                      monthlyWaste: _monthlyWaste,
                      onCollectorSelected: _selectCollector,
                    ),
                  ],
                  const SizedBox(height: 60),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTabChanged: (index) {
          if (!mounted) return;
          
          setState(() {
            _currentIndex = index;
          });
          
          switch (index) {
            case 0:
              // Accueil: rester sur place
              break;
            case 1:
              if (mounted) AppRoutes.pushNamed(context, AppRoutes.monetization);
              break;
            case 2:
              if (mounted) AppRoutes.pushNamed(context, AppRoutes.pourMoi);
              break;
            case 3:
              if (mounted) AppRoutes.pushNamed(context, AppRoutes.budget);
              break;
            case 4:
              if (mounted) AppRoutes.pushNamed(context, AppRoutes.profile);
              break;
          }
        },
      ),
    );
  }

  void _selectCollector(Map<String, dynamic> collector) {
    // Afficher les détails du collecteur sélectionné
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.local_shipping,
              color: AppTheme.primaryColor,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Collecteur sélectionné',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Informations du collecteur
                _buildCollectorInfoRow(
                  'Nom',
                  collector['name'] ?? 'N/A',
                  Icons.person,
                ),
                _buildCollectorInfoRow(
                  'Distance',
                  '${(collector['distance'] ?? 0.0).toStringAsFixed(1)} km',
                  Icons.location_on,
                ),
                _buildCollectorInfoRow(
                  'Temps d\'arrivée',
                  collector['eta'] ?? 'N/A',
                  Icons.access_time,
                ),
                _buildCollectorInfoRow(
                  'Note',
                  '${(collector['rating'] ?? 0.0).toStringAsFixed(1)}/5',
                  Icons.star,
                ),
                if (collector['specialization'] != null)
                  _buildCollectorInfoRow(
                    'Spécialisation',
                    collector['specialization'],
                    Icons.category,
                  ),
                if (collector['phone'] != null && collector['phone'].isNotEmpty)
                  _buildCollectorInfoRow(
                    'Téléphone',
                    collector['phone'],
                    Icons.phone,
                  ),
                
                const SizedBox(height: 16),
                
                // Statut de disponibilité
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (collector['is_available'] ?? false) 
                        ? AppTheme.successColor.withOpacity(0.1)
                        : AppTheme.warningColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: (collector['is_available'] ?? false)
                          ? AppTheme.successColor.withOpacity(0.3)
                          : AppTheme.warningColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        (collector['is_available'] ?? false) 
                            ? Icons.check_circle 
                            : Icons.warning,
                        color: (collector['is_available'] ?? false)
                            ? AppTheme.successColor
                            : AppTheme.warningColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          (collector['is_available'] ?? false)
                              ? 'Ce collecteur est disponible pour la collecte'
                              : 'Ce collecteur est actuellement occupé',
                          style: TextStyle(
                            color: (collector['is_available'] ?? false)
                                ? AppTheme.successColor
                                : AppTheme.warningColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Fermer',
              style: TextStyle(color: AppTheme.onBackgroundColor.withOpacity(0.7)),
            ),
          ),
          if (collector['is_available'] ?? false)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _proceedWithCollector(collector);
              },
              icon: const Icon(Icons.check),
              label: const Text('Continuer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successColor,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  void _proceedWithCollector(Map<String, dynamic> collector) {
    // Rediriger vers la page de monétisation avec le collecteur pré-sélectionné
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: AppTheme.successColor,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text('Collecteur confirmé !'),
          ],
        ),
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Vous avez sélectionné ${collector['name']} comme collecteur.',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Text(
                'Vous allez être redirigé vers la page de monétisation pour finaliser votre vente.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.onBackgroundColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: TextStyle(color: AppTheme.onBackgroundColor.withOpacity(0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Naviguer vers la page de monétisation
              if (mounted) {
                AppRoutes.pushNamed(context, AppRoutes.monetization);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Aller à la monétisation'),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectorInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.onBackgroundColor.withOpacity(0.7), size: 20),
        const SizedBox(width: 12),
        Text(
          '$label : ',
          style: TextStyle(
            color: AppTheme.onBackgroundColor.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: AppTheme.onBackgroundColor.withOpacity(0.9),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
