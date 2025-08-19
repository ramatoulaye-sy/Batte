import 'package:flutter/material.dart';
import 'package:batte/core/app_theme.dart';

class EnterprisePage extends StatefulWidget {
  const EnterprisePage({super.key});

  @override
  State<EnterprisePage> createState() => _EnterprisePageState();
}

class _EnterprisePageState extends State<EnterprisePage> {
  int _selectedTabIndex = 0;
  bool _isOnline = true;
  double _monthlyWaste = 0.0;
  double _monthlySavings = 0.0;
  int _complianceScore = 0;

  // Données des déchets industriels
  final List<Map<String, dynamic>> _industrialWaste = [
    {
      'type': 'Métaux',
      'quantity': 1250.0,
      'unit': 'kg',
      'category': 'Recyclable',
      'hazardLevel': 'Faible',
      'disposalCost': 45000.0,
      'recyclingValue': 75000.0,
      'color': AppTheme.wasteMetalColor,
      'icon': Icons.hardware,
    },
    {
      'type': 'Plastiques Industriels',
      'quantity': 890.0,
      'unit': 'kg',
      'category': 'Recyclable',
      'hazardLevel': 'Moyen',
      'disposalCost': 32000.0,
      'recyclingValue': 53400.0,
      'color': AppTheme.wastePlasticColor,
      'icon': Icons.local_drink,
    },
    {
      'type': 'Cartons/Emballages',
      'quantity': 2100.0,
      'unit': 'kg',
      'category': 'Recyclable',
      'hazardLevel': 'Faible',
      'disposalCost': 15000.0,
      'recyclingValue': 42000.0,
      'color': AppTheme.wastePaperColor,
      'icon': Icons.inventory_2,
    },
    {
      'type': 'Déchets Électroniques',
      'quantity': 180.0,
      'unit': 'kg',
      'category': 'Spécial',
      'hazardLevel': 'Élevé',
      'disposalCost': 80000.0,
      'recyclingValue': 120000.0,
      'color': AppTheme.accentColor,
      'icon': Icons.devices,
    },
    {
      'type': 'Huiles Usagées',
      'quantity': 45.0,
      'unit': 'L',
      'category': 'Dangereux',
      'hazardLevel': 'Élevé',
      'disposalCost': 25000.0,
      'recyclingValue': 18000.0,
      'color': AppTheme.errorColor,
      'icon': Icons.opacity,
    },
  ];

  // Demandes de collecte
  final List<Map<String, dynamic>> _collectionRequests = [
    {
      'id': 'REQ001',
      'client': 'Usine Textile Conakry',
      'wasteType': 'Tissus et Fibres',
      'quantity': 500.0,
      'unit': 'kg',
      'urgency': 'Normale',
      'location': 'Conakry, Kaloum',
      'requestDate': '2024-01-28',
      'status': 'En attente',
      'estimatedValue': 25000.0,
    },
    {
      'id': 'REQ002',
      'client': 'Boulangerie Moderne',
      'wasteType': 'Déchets Organiques',
      'quantity': 200.0,
      'unit': 'kg',
      'urgency': 'Urgente',
      'location': 'Conakry, Ratoma',
      'requestDate': '2024-01-28',
      'status': 'Confirmée',
      'estimatedValue': 8000.0,
    },
    {
      'id': 'REQ003',
      'client': 'Atelier Mécanique',
      'wasteType': 'Huiles et Graisses',
      'quantity': 80.0,
      'unit': 'L',
      'urgency': 'Normale',
      'location': 'Conakry, Dixinn',
      'requestDate': '2024-01-27',
      'status': 'En cours',
      'estimatedValue': 15000.0,
    },
  ];

  // Rapports de conformité
  final List<Map<String, dynamic>> _complianceReports = [
    {
      'period': 'Janvier 2024',
      'score': 92,
      'status': 'Conforme',
      'inspections': 3,
      'violations': 0,
      'recommendations': 2,
      'nextInspection': '2024-02-15',
    },
    {
      'period': 'Décembre 2023',
      'score': 88,
      'status': 'Conforme',
      'inspections': 2,
      'violations': 1,
      'recommendations': 3,
      'nextInspection': '2024-01-15',
    },
    {
      'period': 'Novembre 2023',
      'score': 95,
      'status': 'Exemplaire',
      'inspections': 4,
      'violations': 0,
      'recommendations': 1,
      'nextInspection': '2024-01-15',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadEnterpriseData();
  }

  void _loadEnterpriseData() {
    // Simuler le chargement des données de l'entreprise
    setState(() {
      _monthlyWaste = _industrialWaste.fold(0.0, (sum, waste) => sum + waste['quantity']);
      _monthlySavings = _industrialWaste.fold(0.0, (sum, waste) => 
        sum + (waste['recyclingValue'] - waste['disposalCost']));
      _complianceScore = _complianceReports.isNotEmpty 
        ? _complianceReports.first['score'] 
        : 0;
    });
  }

  void _showWasteDetails(Map<String, dynamic> waste) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              waste['icon'],
              color: waste['color'],
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(waste['type']),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Quantité', '${waste['quantity']} ${waste['unit']}'),
            _buildDetailRow('Catégorie', waste['category']),
            _buildDetailRow('Niveau de danger', waste['hazardLevel']),
            _buildDetailRow('Coût d\'élimination', '${waste['disposalCost'].toStringAsFixed(0)} GNF'),
            _buildDetailRow('Valeur recyclage', '${waste['recyclingValue'].toStringAsFixed(0)} GNF'),
            _buildDetailRow('Économies', '${(waste['recyclingValue'] - waste['disposalCost']).toStringAsFixed(0)} GNF'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Fermer',
              style: TextStyle(color: AppTheme.primaryColor),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _scheduleCollection(waste);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: AppTheme.onPrimaryColor,
            ),
            child: const Text('Programmer Collecte'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppTheme.onBackgroundColor.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _scheduleCollection(Map<String, dynamic> waste) {
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
            const Text('Programmer Collecte'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Déchets : ${waste['type']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Quantité : ${waste['quantity']} ${waste['unit']}',
              style: TextStyle(
                color: AppTheme.onBackgroundColor.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Choisissez la date de collecte :',
              style: TextStyle(
                color: AppTheme.onBackgroundColor.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            _buildDateOption('Aujourd\'hui', 'Immédiat'),
            const SizedBox(height: 8),
            _buildDateOption('Demain', '24h'),
            const SizedBox(height: 8),
            _buildDateOption('Cette semaine', '7 jours'),
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

  Widget _buildDateOption(String title, String subtitle) {
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
              content: Text('Collecte programmée pour $title'),
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

  void _showRequestDetails(Map<String, dynamic> request) {
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
                    Icons.business,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request['client'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Demande ${request['id']}',
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
                    _buildRequestDetail('Type de déchets', request['wasteType']),
                    _buildRequestDetail('Quantité', '${request['quantity']} ${request['unit']}'),
                    _buildRequestDetail('Urgence', request['urgency']),
                    _buildRequestDetail('Localisation', request['location']),
                    _buildRequestDetail('Date de demande', request['requestDate']),
                    _buildRequestDetail('Statut', request['status']),
                    _buildRequestDetail('Valeur estimée', '${request['estimatedValue'].toStringAsFixed(0)} GNF'),
                    const SizedBox(height: 20),
                    if (request['status'] == 'En attente') ...[
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _acceptRequest(request);
                              },
                              icon: const Icon(Icons.check),
                              label: const Text('Accepter'),
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
                                _rejectRequest(request);
                              },
                              icon: const Icon(Icons.close),
                              label: const Text('Refuser'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.errorColor,
                                side: BorderSide(color: AppTheme.errorColor),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else if (request['status'] == 'Confirmée') ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _startCollection(request);
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Démarrer Collecte'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: AppTheme.onPrimaryColor,
                          ),
                        ),
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

  Widget _buildRequestDetail(String label, String value) {
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

  void _acceptRequest(Map<String, dynamic> request) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Demande ${request['id']} acceptée'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _rejectRequest(Map<String, dynamic> request) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Demande ${request['id']} refusée'),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  void _startCollection(Map<String, dynamic> request) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Collecte démarrée pour ${request['client']}'),
        backgroundColor: AppTheme.infoColor,
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
          'Entreprise',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _isOnline ? AppTheme.successColor : AppTheme.errorColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isOnline ? Icons.wifi : Icons.wifi_off,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  _isOnline ? 'En ligne' : 'Hors ligne',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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
                      Icons.business,
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
                            'Gestion Industrielle',
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
                        'Déchets Mensuels',
                        '${_monthlyWaste.toStringAsFixed(0)} kg',
                        Icons.inventory,
                        Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'Économies',
                        '${_monthlySavings.toStringAsFixed(0)} GNF',
                        Icons.savings,
                        AppTheme.secondaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'Conformité',
                        '$_complianceScore%',
                        Icons.verified,
                        AppTheme.successColor,
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
                _buildTabButton(0, 'Déchets', Icons.inventory),
                _buildTabButton(1, 'Demandes', Icons.request_page),
                _buildTabButton(2, 'Conformité', Icons.verified_user),
              ],
            ),
          ),

          // Contenu des onglets
          Expanded(
            child: IndexedStack(
              index: _selectedTabIndex,
              children: [
                _buildWasteTab(),
                _buildRequestsTab(),
                _buildComplianceTab(),
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

  Widget _buildWasteTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _industrialWaste.length,
      itemBuilder: (context, index) {
        final waste = _industrialWaste[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: () => _showWasteDetails(waste),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: waste['color'].withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      waste['icon'],
                      color: waste['color'],
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          waste['type'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${waste['quantity']} ${waste['unit']} • ${waste['category']}',
                          style: TextStyle(
                            color: AppTheme.onBackgroundColor.withValues(alpha: 0.7),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: waste['hazardLevel'] == 'Élevé' 
                                  ? AppTheme.errorColor.withValues(alpha: 0.1)
                                  : waste['hazardLevel'] == 'Moyen'
                                    ? AppTheme.warningColor.withValues(alpha: 0.1)
                                    : AppTheme.successColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                waste['hazardLevel'],
                                style: TextStyle(
                                  color: waste['hazardLevel'] == 'Élevé' 
                                    ? AppTheme.errorColor
                                    : waste['hazardLevel'] == 'Moyen'
                                      ? AppTheme.warningColor
                                      : AppTheme.successColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${(waste['recyclingValue'] - waste['disposalCost']).toStringAsFixed(0)} GNF',
                              style: TextStyle(
                                color: AppTheme.successColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppTheme.onBackgroundColor.withValues(alpha: 0.3),
                    size: 20,
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
        final statusColor = request['status'] == 'En attente' 
          ? AppTheme.warningColor
          : request['status'] == 'Confirmée'
            ? AppTheme.successColor
            : AppTheme.infoColor;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: () => _showRequestDetails(request),
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
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          request['status'],
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
                      Text(
                        request['location'],
                        style: TextStyle(
                          color: AppTheme.onBackgroundColor.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
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
                  if (request['urgency'] == 'Urgente') ...[
                    const SizedBox(height: 8),
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
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Urgente',
                            style: TextStyle(
                              color: AppTheme.errorColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildComplianceTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _complianceReports.length,
      itemBuilder: (context, index) {
        final report = _complianceReports[index];
        final scoreColor = report['score'] >= 90 
          ? AppTheme.successColor
          : report['score'] >= 80
            ? AppTheme.warningColor
            : AppTheme.errorColor;
        
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
                            report['period'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            'Score de conformité',
                            style: TextStyle(
                              color: AppTheme.onBackgroundColor.withValues(alpha: 0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: scoreColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${report['score']}%',
                        style: TextStyle(
                          color: scoreColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildComplianceMetric('Inspections', '${report['inspections']}'),
                    const SizedBox(width: 16),
                    _buildComplianceMetric('Violations', '${report['violations']}'),
                    const SizedBox(width: 16),
                    _buildComplianceMetric('Recommandations', '${report['recommendations']}'),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.infoColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: AppTheme.infoColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Prochaine inspection : ${report['nextInspection']}',
                        style: TextStyle(
                          color: AppTheme.infoColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildComplianceMetric(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.onBackgroundColor.withValues(alpha: 0.7),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
