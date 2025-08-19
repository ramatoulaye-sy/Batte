import 'package:flutter/material.dart';
import 'package:batte/core/app_theme.dart';

class CollectorPage extends StatefulWidget {
  const CollectorPage({super.key});

  @override
  State<CollectorPage> createState() => _CollectorPageState();
}

class _CollectorPageState extends State<CollectorPage> {
  int _selectedTabIndex = 0;
  bool _isOnline = true;
  bool _isOnDuty = true;
  double _dailyEarnings = 0.0;
  int _completedCollections = 0;
  double _totalDistance = 0.0;

  // Collectes en cours et planifiées
  final List<Map<String, dynamic>> _activeCollections = [
    {
      'id': 'COL001',
      'client': 'Sofia Diallo',
      'address': 'Conakry, Kaloum, Rue 12',
      'wasteType': 'Plastique et Verre',
      'quantity': 8.5,
      'unit': 'kg',
      'estimatedValue': 1275.0,
      'status': 'En cours',
      'priority': 'Normale',
      'distance': 2.3,
      'estimatedTime': '15 min',
      'coordinates': {'lat': 9.5370, 'lng': -13.6785},
    },
    {
      'id': 'COL002',
      'client': 'Anabelle Camara',
      'address': 'Conakry, Ratoma, Avenue 8',
      'wasteType': 'Organique et Papier',
      'quantity': 12.0,
      'unit': 'kg',
      'estimatedValue': 960.0,
      'status': 'Planifiée',
      'priority': 'Urgente',
      'distance': 4.1,
      'estimatedTime': '25 min',
      'coordinates': {'lat': 9.5450, 'lng': -13.6780},
    },
    {
      'id': 'COL003',
      'client': 'Victoria Barry',
      'address': 'Conakry, Dixinn, Boulevard 15',
      'wasteType': 'Métal et Électronique',
      'quantity': 15.2,
      'unit': 'kg',
      'estimatedValue': 4560.0,
      'status': 'Planifiée',
      'priority': 'Normale',
      'distance': 6.8,
      'estimatedTime': '35 min',
      'coordinates': {'lat': 9.5500, 'lng': -13.6750},
    },
  ];

  // Demandes de collecte
  final List<Map<String, dynamic>> _collectionRequests = [
    {
      'id': 'REQ001',
      'client': 'Mariama Diallo',
      'address': 'Conakry, Kaloum, Rue 5',
      'wasteType': 'Plastique',
      'quantity': 5.0,
      'unit': 'kg',
      'estimatedValue': 750.0,
      'urgency': 'Normale',
      'requestDate': '2024-01-28',
      'distance': 1.8,
      'coordinates': {'lat': 9.5380, 'lng': -13.6790},
    },
    {
      'id': 'REQ002',
      'client': 'Fatou Camara',
      'address': 'Conakry, Ratoma, Avenue 12',
      'wasteType': 'Organique',
      'quantity': 8.0,
      'unit': 'kg',
      'estimatedValue': 640.0,
      'urgency': 'Urgente',
      'requestDate': '2024-01-28',
      'distance': 3.2,
      'coordinates': {'lat': 9.5420, 'lng': -13.6770},
    },
    {
      'id': 'REQ003',
      'client': 'Aissatou Barry',
      'address': 'Conakry, Dixinn, Boulevard 8',
      'wasteType': 'Verre et Papier',
      'quantity': 10.5,
      'unit': 'kg',
      'estimatedValue': 1680.0,
      'urgency': 'Normale',
      'requestDate': '2024-01-27',
      'distance': 5.5,
      'coordinates': {'lat': 9.5480, 'lng': -13.6760},
    },
  ];

  // Historique des collectes
  final List<Map<String, dynamic>> _collectionHistory = [
    {
      'id': 'COL001',
      'client': 'Sofia Diallo',
      'date': '2024-01-27',
      'wasteType': 'Plastique',
      'quantity': 6.2,
      'unit': 'kg',
      'earnings': 930.0,
      'rating': 5,
      'feedback': 'Service excellent, très ponctuel !',
    },
    {
      'id': 'COL002',
      'client': 'Anabelle Camara',
      'date': '2024-01-26',
      'wasteType': 'Organique',
      'quantity': 4.8,
      'unit': 'kg',
      'earnings': 384.0,
      'rating': 4,
      'feedback': 'Bon service, un peu en retard',
    },
    {
      'id': 'COL003',
      'client': 'Victoria Barry',
      'date': '2024-01-25',
      'wasteType': 'Métal',
      'quantity': 12.5,
      'unit': 'kg',
      'earnings': 3750.0,
      'rating': 5,
      'feedback': 'Parfait ! Très professionnel',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadCollectorData();
  }

  void _loadCollectorData() {
    // Simuler le chargement des données du collecteur
    setState(() {
      _dailyEarnings = _collectionHistory.fold(0.0, (sum, collection) => sum + collection['earnings']);
      _completedCollections = _collectionHistory.length;
      _totalDistance = _activeCollections.fold(0.0, (sum, collection) => sum + collection['distance']);
    });
  }

  void _toggleOnlineStatus() {
    setState(() {
      _isOnline = !_isOnline;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isOnline ? 'Vous êtes maintenant en ligne' : 'Vous êtes maintenant hors ligne'),
        backgroundColor: _isOnline ? AppTheme.successColor : AppTheme.errorColor,
      ),
    );
  }

  void _toggleDutyStatus() {
    setState(() {
      _isOnDuty = !_isOnDuty;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isOnDuty ? 'Vous êtes maintenant en service' : 'Vous êtes maintenant hors service'),
        backgroundColor: _isOnDuty ? AppTheme.successColor : AppTheme.warningColor,
      ),
    );
  }

  void _showCollectionDetails(Map<String, dynamic> collection) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          collection['client'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          collection['address'],
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCollectionDetail('Type de déchets', collection['wasteType']),
                    _buildCollectionDetail('Quantité', '${collection['quantity']} ${collection['unit']}'),
                    _buildCollectionDetail('Valeur estimée', '${collection['estimatedValue'].toStringAsFixed(0)} GNF'),
                    _buildCollectionDetail('Distance', '${collection['distance']} km'),
                    _buildCollectionDetail('Temps estimé', collection['estimatedTime']),
                    _buildCollectionDetail('Statut', collection['status']),
                    const SizedBox(height: 20),
                    if (collection['status'] == 'Planifiée') ...[
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _startCollection(collection);
                              },
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Démarrer'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: AppTheme.onPrimaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _rescheduleCollection(collection);
                              },
                              icon: const Icon(Icons.schedule),
                              label: const Text('Reprogrammer'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primaryColor,
                                side: BorderSide(color: AppTheme.primaryColor),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else if (collection['status'] == 'En cours') ...[
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _completeCollection(collection);
                              },
                              icon: const Icon(Icons.check),
                              label: const Text('Terminer'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.successColor,
                                foregroundColor: AppTheme.onPrimaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _reportIssue(collection);
                              },
                              icon: const Icon(Icons.report_problem),
                              label: const Text('Problème'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.errorColor,
                                side: BorderSide(color: AppTheme.errorColor),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectionDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppTheme.onBackgroundColor.withValues(alpha: 0.7),
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  void _startCollection(Map<String, dynamic> collection) {
    setState(() {
      collection['status'] = 'En cours';
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Collecte ${collection['id']} démarrée'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }

  void _completeCollection(Map<String, dynamic> collection) {
    setState(() {
      collection['status'] = 'Terminée';
      _completedCollections++;
      _dailyEarnings += collection['estimatedValue'];
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Collecte ${collection['id']} terminée ! +${collection['estimatedValue'].toStringAsFixed(0)} GNF'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _rescheduleCollection(Map<String, dynamic> collection) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.schedule,
              color: AppTheme.primaryColor,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text('Reprogrammer'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Client : ${collection['client']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Choisissez la nouvelle date :',
              style: TextStyle(
                color: AppTheme.onBackgroundColor.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            _buildRescheduleOption('Aujourd\'hui', 'Immédiat'),
            const SizedBox(height: 8),
            _buildRescheduleOption('Demain', '24h'),
            const SizedBox(height: 8),
            _buildRescheduleOption('Cette semaine', '7 jours'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: TextStyle(color: AppTheme.onBackgroundColor.withValues(alpha: 0.7)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRescheduleOption(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Collecte reprogrammée pour $title'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: AppTheme.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppTheme.primaryColor.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.primaryColor.withValues(alpha: 0.7),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _reportIssue(Map<String, dynamic> collection) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.report_problem,
              color: AppTheme.errorColor,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text('Signaler un problème'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Client : ${collection['client']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Sélectionnez le type de problème :',
              style: TextStyle(
                color: AppTheme.onBackgroundColor.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            _buildIssueOption('Client absent', 'Pas de réponse'),
            const SizedBox(height: 8),
            _buildIssueOption('Adresse incorrecte', 'Localisation erronée'),
            const SizedBox(height: 8),
            _buildIssueOption('Déchets insuffisants', 'Quantité minimale non atteinte'),
            const SizedBox(height: 8),
            _buildIssueOption('Autre', 'Problème spécifique'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: TextStyle(color: AppTheme.onBackgroundColor.withValues(alpha: 0.7)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIssueOption(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.errorColor.withValues(alpha: 0.3)),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Problème signalé : $title'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Icon(
              Icons.warning,
              color: AppTheme.errorColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppTheme.errorColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppTheme.errorColor.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.errorColor.withValues(alpha: 0.7),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _acceptRequest(Map<String, dynamic> request) {
    setState(() {
      _activeCollections.add({
        ...request,
        'id': 'COL${_activeCollections.length + 1}',
        'status': 'Planifiée',
        'priority': request['urgency'] == 'Urgente' ? 'Urgente' : 'Normale',
      });
      _collectionRequests.remove(request);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Demande ${request['id']} acceptée et ajoutée à vos collectes'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Collecteur',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Statut en ligne/hors ligne
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: _toggleOnlineStatus,
              icon: Icon(
                _isOnline ? Icons.wifi : Icons.wifi_off,
                color: _isOnline ? AppTheme.successColor : AppTheme.errorColor,
              ),
            ),
          ),
          // Statut en service/hors service
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: _toggleDutyStatus,
              icon: Icon(
                _isOnDuty ? Icons.work : Icons.work_off,
                color: _isOnDuty ? AppTheme.successColor : AppTheme.warningColor,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // En-tête avec statistiques
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: AppTheme.primaryGradient,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.local_shipping,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tableau de Bord',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Collecteur Actif',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Gains du Jour',
                        '${_dailyEarnings.toStringAsFixed(0)} GNF',
                        Icons.monetization_on,
                        AppTheme.secondaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'Collectes',
                        '$_completedCollections',
                        Icons.check_circle,
                        Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'Distance',
                        '${_totalDistance.toStringAsFixed(1)} km',
                        Icons.route,
                        AppTheme.accentColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Onglets
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Row(
              children: [
                _buildTabButton(0, 'Collectes', Icons.local_shipping),
                _buildTabButton(1, 'Demandes', Icons.request_page),
                _buildTabButton(2, 'Historique', Icons.history),
              ],
            ),
          ),

          // Contenu des onglets
          Expanded(
            child: IndexedStack(
              index: _selectedTabIndex,
              children: [
                _buildCollectionsTab(),
                _buildRequestsTab(),
                _buildHistoryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
                      Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String label, IconData icon) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _selectedTabIndex = index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: isSelected ? AppTheme.onPrimaryColor : AppTheme.onBackgroundColor.withValues(alpha: 0.7),
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? AppTheme.onPrimaryColor : AppTheme.onBackgroundColor.withValues(alpha: 0.7),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCollectionsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _activeCollections.length,
      itemBuilder: (context, index) {
        final collection = _activeCollections[index];
        final statusColor = collection['status'] == 'En cours' 
          ? AppTheme.infoColor
          : collection['status'] == 'Planifiée'
            ? AppTheme.warningColor
            : AppTheme.successColor;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: () => _showCollectionDetails(collection),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              collection['client'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              '${collection['wasteType']} • ${collection['quantity']} ${collection['unit']}',
                              style: TextStyle(
                                color: AppTheme.onBackgroundColor.withValues(alpha: 0.7),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          collection['status'],
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: AppTheme.primaryColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          collection['address'],
                          style: TextStyle(
                            color: AppTheme.onBackgroundColor.withValues(alpha: 0.7),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Text(
                        '${collection['estimatedValue'].toStringAsFixed(0)} GNF',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.route,
                        color: AppTheme.accentColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${collection['distance']} km • ${collection['estimatedTime']}',
                        style: TextStyle(
                          color: AppTheme.accentColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (collection['priority'] == 'Urgente')
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.errorColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.priority_high,
                                color: AppTheme.errorColor,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Urgente',
                                style: TextStyle(
                                  color: AppTheme.errorColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRequestsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _collectionRequests.length,
      itemBuilder: (context, index) {
        final request = _collectionRequests[index];
        final urgencyColor = request['urgency'] == 'Urgente' 
          ? AppTheme.errorColor
          : AppTheme.warningColor;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request['client'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            '${request['wasteType']} • ${request['quantity']} ${request['unit']}',
                            style: TextStyle(
                              color: AppTheme.onBackgroundColor.withValues(alpha: 0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: urgencyColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        request['urgency'],
                        style: TextStyle(
                          color: urgencyColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: AppTheme.primaryColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        request['address'],
                        style: TextStyle(
                          color: AppTheme.onBackgroundColor.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Text(
                      '${request['estimatedValue'].toStringAsFixed(0)} GNF',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.route,
                      color: AppTheme.accentColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${request['distance']} km',
                      style: TextStyle(
                        color: AppTheme.accentColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 120,
                      child: ElevatedButton.icon(
                        onPressed: () => _acceptRequest(request),
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Accepter'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.successColor,
                          foregroundColor: AppTheme.onPrimaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _collectionHistory.length,
      itemBuilder: (context, index) {
        final collection = _collectionHistory[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            collection['client'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            '${collection['wasteType']} • ${collection['quantity']} ${collection['unit']}',
                            style: TextStyle(
                              color: AppTheme.onBackgroundColor.withValues(alpha: 0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${collection['earnings'].toStringAsFixed(0)} GNF',
                          style: TextStyle(
                            color: AppTheme.successColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < collection['rating'] ? Icons.star : Icons.star_border,
                              color: AppTheme.warningColor,
                              size: 16,
                            );
                          }),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: AppTheme.primaryColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      collection['date'],
                      style: TextStyle(
                        color: AppTheme.onBackgroundColor.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      collection['feedback'],
                      style: TextStyle(
                        color: AppTheme.onBackgroundColor.withValues(alpha: 0.8),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
