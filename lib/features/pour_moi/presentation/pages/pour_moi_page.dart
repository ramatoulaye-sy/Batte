import 'package:flutter/material.dart';
import 'package:batte/core/app_theme.dart';

class PourMoiPage extends StatefulWidget {
  const PourMoiPage({super.key});

  @override
  State<PourMoiPage> createState() => _PourMoiPageState();
}

class _PourMoiPageState extends State<PourMoiPage> {
  final _chatController = TextEditingController();
  final _scrollController = ScrollController();
  
  bool _isTyping = false;
  int _selectedTabIndex = 0;

  // Messages de chat simulés
  final List<Map<String, dynamic>> _chatMessages = [
    {
      'type': 'user',
      'message': 'Bonjour ! Comment transformer le plastique en matériel de couture ?',
      'timestamp': '10:30',
    },
    {
      'type': 'ai',
      'message': 'Bonjour ! C\'est une excellente idée ! Voici comment procéder :\n\n1. Collectez des bouteilles en plastique propres\n2. Découpez-les en bandes fines\n3. Faites-les fondre à 180°C\n4. Étirez pour créer des fibres\n5. Tressez ou cousez pour créer des accessoires\n\nVoulez-vous que je vous envoie une vidéo détaillée ?',
      'timestamp': '10:31',
    },
    {
      'type': 'user',
      'message': 'Oui, c\'est possible en Guinée ?',
      'timestamp': '10:32',
    },
    {
      'type': 'ai',
      'message': 'Absolument ! En Guinée, vous pouvez utiliser un four traditionnel ou un réchaud à gaz. Les températures sont parfaites pour cette transformation. Je vous recommande de commencer avec de petites quantités pour tester.\n\nVoulez-vous que je vous connecte avec d\'autres couturières qui font déjà cela ?',
      'timestamp': '10:33',
    },
  ];

  // Vidéos éducatives
  final List<Map<String, dynamic>> _educationalVideos = [
    {
      'title': 'Transformer le plastique en fibres textiles',
      'description': 'Apprenez à créer des fibres textiles à partir de bouteilles en plastique recyclées.',
      'duration': '8:45',
      'thumbnail': '🎥',
      'category': 'Recyclage',
      'isNew': true,
    },
    {
      'title': 'Compostage des déchets organiques',
      'description': 'Guide complet pour créer votre propre compost à la maison.',
      'duration': '12:30',
      'thumbnail': '🌱',
      'category': 'Compostage',
      'isNew': false,
    },
    {
      'title': 'Artisanat avec du verre recyclé',
      'description': 'Créez de magnifiques objets décoratifs avec du verre recyclé.',
      'duration': '15:20',
      'thumbnail': '🪟',
      'category': 'Artisanat',
      'isNew': true,
    },
    {
      'title': 'Fabrication de savon écologique',
      'description': 'Apprenez à fabriquer du savon avec des huiles recyclées.',
      'duration': '20:15',
      'thumbnail': '🧼',
      'category': 'Cosmétiques',
      'isNew': false,
    },
  ];

  // Solutions locales
  final List<Map<String, dynamic>> _localSolutions = [
    {
      'title': 'Atelier Couture Écologique',
      'description': 'Fatou Camara transforme le plastique en accessoires de mode',
      'location': 'Conakry, Kaloum',
      'rating': 4.8,
      'contact': '+224 123 456 78',
      'services': ['Couture', 'Recyclage', 'Formation'],
      'image': '👗',
    },
    {
      'title': 'Ferme Urbaine Bio',
      'description': 'Mariama Diallo produit des légumes bio avec du compost local',
      'location': 'Conakry, Ratoma',
      'rating': 4.9,
      'contact': '+224 876 543 21',
      'services': ['Agriculture', 'Compostage', 'Vente directe'],
      'image': '🌾',
    },
    {
      'title': 'Artisanat Verre Recyclé',
      'description': 'Aissatou Barry crée des bijoux avec du verre recyclé',
      'location': 'Conakry, Dixinn',
      'rating': 4.7,
      'contact': '+224 112 233 44',
      'services': ['Bijouterie', 'Recyclage', 'Ateliers'],
      'image': '💎',
    },
  ];

  @override
  void dispose() {
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_chatController.text.trim().isEmpty) return;

    final message = _chatController.text.trim();
    setState(() {
      _chatMessages.add({
        'type': 'user',
        'message': message,
        'timestamp': _getCurrentTime(),
      });
      _isTyping = true;
    });

    _chatController.clear();
    _scrollToBottom();

    // Simuler une réponse IA
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _chatMessages.add({
            'type': 'ai',
            'message': _generateAIResponse(message),
            'timestamp': _getCurrentTime(),
          });
        });
        _scrollToBottom();
      }
    });
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  String _generateAIResponse(String userMessage) {
    final message = userMessage.toLowerCase();
    
    if (message.contains('plastique') && message.contains('couture')) {
      return 'Excellent choix ! Le plastique peut être transformé en fibres textiles. Commencez par collecter des bouteilles propres, découpez-les en bandes, puis faites-les fondre à 180°C. Voulez-vous que je vous connecte avec Fatou Camara qui fait déjà cela ?';
    } else if (message.contains('compost') || message.contains('organique')) {
      return 'Le compostage est parfait pour vos déchets organiques ! Mélangez déchets verts et bruns, ajoutez de l\'eau et retournez régulièrement. En 3-6 mois, vous aurez un excellent engrais !';
    } else if (message.contains('verre') || message.contains('recyclé')) {
      return 'Le verre recyclé est idéal pour l\'artisanat ! Aissatou Barry crée de magnifiques bijoux. Voulez-vous que je vous mette en contact ?';
    } else {
      return 'Merci pour votre question ! Je peux vous aider avec le recyclage, le compostage, l\'artisanat écologique et plus encore. Que souhaitez-vous savoir ?';
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showVideoDetails(Map<String, dynamic> video) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Text(video['thumbnail'], style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                video['title'],
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              video['description'],
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    video['category'],
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    video['duration'],
                    style: TextStyle(
                      color: AppTheme.accentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Lecture de la vidéo : ${video['title']}'),
                  backgroundColor: AppTheme.primaryColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: AppTheme.onPrimaryColor,
            ),
            child: const Text('Regarder'),
          ),
        ],
      ),
    );
  }

  void _showSolutionDetails(Map<String, dynamic> solution) {
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
                  Text(
                    solution['image'],
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          solution['title'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          solution['location'],
                          style: const TextStyle(
                            color: Colors.white70,
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
                    Text(
                      solution['description'],
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Icon(Icons.star, color: AppTheme.warningColor),
                        const SizedBox(width: 8),
                        Text(
                          '${solution['rating']}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Services proposés :',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: solution['services'].map<Widget>((service) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            service,
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Simuler un appel
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Appel vers ${solution['contact']}'),
                                  backgroundColor: AppTheme.successColor,
                                ),
                              );
                            },
                            icon: const Icon(Icons.phone),
                            label: const Text('Appeler'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryColor,
                              side: BorderSide(color: AppTheme.primaryColor),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Simuler un message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Message envoyé à ${solution['title']}'),
                                  backgroundColor: AppTheme.primaryColor,
                                ),
                              );
                            },
                            icon: const Icon(Icons.message),
                            label: const Text('Message'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: AppTheme.onPrimaryColor,
                            ),
                          ),
                        ),
                      ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Pour Moi',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add_business,
              color: AppTheme.primaryColor,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fonctionnalité "Je propose un service" bientôt disponible !'),
                  backgroundColor: AppTheme.infoColor,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Onglets
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Row(
              children: [
                _buildTabButton(0, 'Chatbox IA', Icons.chat),
                _buildTabButton(1, 'Vidéos', Icons.video_library),
                _buildTabButton(2, 'Solutions', Icons.lightbulb),
              ],
            ),
          ),

          // Contenu des onglets
          Expanded(
            child: IndexedStack(
              index: _selectedTabIndex,
              children: [
                _buildChatTab(),
                _buildVideosTab(),
                _buildSolutionsTab(),
              ],
            ),
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

  Widget _buildChatTab() {
    return Column(
      children: [
        // Messages
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _chatMessages.length + (_isTyping ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _chatMessages.length && _isTyping) {
                return _buildTypingIndicator();
              }
              return _buildChatMessage(_chatMessages[index]);
            },
          ),
        ),

        // Zone de saisie
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            boxShadow: AppTheme.elevatedShadow,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatController,
                  decoration: InputDecoration(
                    hintText: 'Pose ta question...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppTheme.backgroundColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 12),
              FloatingActionButton(
                onPressed: _sendMessage,
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: AppTheme.onPrimaryColor,
                mini: true,
                child: const Icon(Icons.send),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChatMessage(Map<String, dynamic> message) {
    final isUser = message['type'] == 'user';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUser ? AppTheme.primaryColor : AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(5),
                  bottomRight: isUser ? const Radius.circular(5) : const Radius.circular(20),
                ),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message['message'],
                    style: TextStyle(
                      color: isUser ? AppTheme.onPrimaryColor : AppTheme.onBackgroundColor,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message['timestamp'],
                    style: TextStyle(
                      color: isUser ? AppTheme.onPrimaryColor.withValues(alpha: 0.7) : AppTheme.onBackgroundColor.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(20).copyWith(
                bottomRight: const Radius.circular(20),
                bottomLeft: const Radius.circular(5),
              ),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                _buildTypingDot(1),
                _buildTypingDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return AnimatedBuilder(
      animation: AlwaysStoppedAnimation(0),
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.6),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildVideosTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _educationalVideos.length,
      itemBuilder: (context, index) {
        final video = _educationalVideos[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: () => _showVideoDetails(video),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        video['thumbnail'],
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                video['title'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (video['isNew'])
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Nouveau !',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          video['description'],
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
                                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                video['category'],
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              video['duration'],
                              style: TextStyle(
                                color: AppTheme.onBackgroundColor.withValues(alpha: 0.5),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.play_circle_filled,
                    color: AppTheme.primaryColor,
                    size: 32,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSolutionsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _localSolutions.length,
      itemBuilder: (context, index) {
        final solution = _localSolutions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: () => _showSolutionDetails(solution),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        solution['image'],
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          solution['title'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          solution['description'],
                          style: TextStyle(
                            color: AppTheme.onBackgroundColor.withValues(alpha: 0.7),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: AppTheme.primaryColor,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              solution['location'],
                              style: TextStyle(
                                color: AppTheme.onBackgroundColor.withValues(alpha: 0.7),
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: AppTheme.warningColor,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  solution['rating'].toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
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
}
