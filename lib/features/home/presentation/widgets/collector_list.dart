import 'package:flutter/material.dart';
import 'package:batte/core/app_theme.dart';

class CollectorList extends StatelessWidget {
  final double monthlyWaste;
  final Function(Map<String, dynamic>) onCollectorSelected;

  const CollectorList({
    super.key,
    required this.monthlyWaste,
    required this.onCollectorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
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
                Icon(
                  Icons.people,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Collecteurs à proximité',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Liste des collecteurs
            _buildCollectorItems(),
            
            const SizedBox(height: 12),
            
            // Bouton pour voir plus de collecteurs
            Center(
              child: TextButton.icon(
                onPressed: () {
                  // Afficher une liste complète des collecteurs
                  _showAllCollectors(context);
                },
                icon: const Icon(Icons.expand_more),
                label: const Text('Voir tous les collecteurs'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectorItems() {
    // Données simulées des collecteurs (à remplacer par des vraies données)
    final collectors = [
      {
        'id': '1',
        'name': 'Mamadou Diallo',
        'distance': 0.8,
        'rating': 4.8,
        'specialization': 'Plastique & Métal',
        'is_available': true,
        'eta': '12:30',
        'phone': '+224 123 456 789',
        'avatar_url': null,
      },
      {
        'id': '2',
        'name': 'Fatou Camara',
        'distance': 1.2,
        'rating': 4.5,
        'specialization': 'Organique & Verre',
        'is_available': true,
        'eta': '13:15',
        'phone': '+224 987 654 321',
        'avatar_url': null,
      },
      {
        'id': '3',
        'name': 'Ibrahima Barry',
        'distance': 1.5,
        'rating': 4.2,
        'specialization': 'Papier & Carton',
        'is_available': false,
        'eta': '13:45',
        'phone': '+224 555 123 456',
        'avatar_url': null,
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: collectors.length,
      itemBuilder: (context, index) => _buildCollectorItem(collectors[index]),
    );
  }

  Widget _buildCollectorItem(Map<String, dynamic> collector) {
    final isAvailable = collector['is_available'] ?? false;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isAvailable 
            ? AppTheme.primaryColor.withOpacity(0.05)
            : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAvailable 
              ? AppTheme.primaryColor.withOpacity(0.2)
              : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // Avatar du collecteur
          CircleAvatar(
            radius: 20,
            backgroundColor: isAvailable ? AppTheme.primaryColor : Colors.grey,
            child: collector['avatar_url'] != null
                ? ClipOval(
                    child: Image.network(
                      collector['avatar_url'],
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  )
                : Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 20,
                  ),
          ),
          
          const SizedBox(width: 12),
          
          // Informations du collecteur
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        collector['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    // Badge de disponibilité
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isAvailable 
                            ? AppTheme.successColor.withOpacity(0.1)
                            : AppTheme.warningColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isAvailable 
                              ? AppTheme.successColor.withOpacity(0.3)
                              : AppTheme.warningColor.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        isAvailable ? 'Disponible' : 'Occupé',
                        style: TextStyle(
                          color: isAvailable 
                              ? AppTheme.successColor
                              : AppTheme.warningColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 2),
                
                Text(
                  collector['specialization'],
                  style: TextStyle(
                    color: AppTheme.onBackgroundColor.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                
                const SizedBox(height: 6),
                
                Row(
                  children: [
                    // Distance
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: AppTheme.primaryColor,
                          size: 14,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${collector['distance'].toStringAsFixed(1)} km',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Note
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: AppTheme.warningColor,
                          size: 14,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${collector['rating'].toStringAsFixed(1)}',
                          style: TextStyle(
                            color: AppTheme.warningColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Temps d'arrivée
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: AppTheme.accentColor,
                          size: 14,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          collector['eta'],
                          style: TextStyle(
                            color: AppTheme.accentColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Bouton d'action
          if (isAvailable)
            ElevatedButton.icon(
              onPressed: () => onCollectorSelected(collector),
              icon: const Icon(Icons.check, size: 16),
              label: const Text('Choisir'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: Text(
                'Indisponible',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showAllCollectors(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
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
                  const Icon(Icons.people, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    'Tous les collecteurs',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
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
                    Text(
                      'Collecteurs dans un rayon de 10km',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.onBackgroundColor.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: _buildCollectorItems(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
