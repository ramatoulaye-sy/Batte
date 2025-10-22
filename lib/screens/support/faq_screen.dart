import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

/// Écran FAQ (Foire Aux Questions)
class FAQScreen extends StatelessWidget {
  const FAQScreen({Key? key}) : super(key: key);

  static final List<Map<String, String>> _faqs = [
    {
      'question': 'Comment fonctionne Battè ?',
      'answer': 'Battè vous permet de recycler vos déchets et de gagner de l\'argent. '
          'Scannez votre poubelle intelligente, nous calculons le poids et le type de déchets, '
          'et vous recevez des gains directement sur votre compte.',
    },
    {
      'question': 'Comment retirer mes gains ?',
      'answer': 'Allez dans l\'onglet Budget, cliquez sur "Retirer", choisissez votre méthode '
          '(Orange Money, MTN, Moov ou virement bancaire) et suivez les instructions. '
          'Le minimum est de 5000 GNF.',
    },
    {
      'question': 'Quels types de déchets sont acceptés ?',
      'answer': 'Nous acceptons : plastique, papier, verre, métal, électronique, textile, '
          'et biodéchets. Chaque type a un tarif différent selon le poids.',
    },
    {
      'question': 'Comment fonctionne le scanner Bluetooth ?',
      'answer': 'Activez le Bluetooth sur votre téléphone, allez dans Recyclage, '
          'cliquez sur "Scanner ma poubelle". La poubelle intelligente détectera automatiquement '
          'le type et le poids de vos déchets.',
    },
    {
      'question': 'Comment appeler un collecteur ?',
      'answer': 'Allez dans Recyclage → Collecteurs de proximité. Vous verrez la liste des collecteurs '
          'disponibles près de vous avec leur note et distance. Cliquez sur "Appeler" pour les contacter.',
    },
    {
      'question': 'Qu\'est-ce que l\'Eco-Score ?',
      'answer': 'L\'Eco-Score mesure votre impact environnemental positif. Plus vous recyclez, '
          'plus votre score augmente. Un score élevé vous donne accès à des bonus et récompenses.',
    },
    {
      'question': 'Comment augmenter mon niveau ?',
      'answer': 'Votre niveau augmente automatiquement en fonction de votre Eco-Score. '
          'Plus vous recyclez régulièrement, plus vous montez de niveau et débloquez des avantages.',
    },
    {
      'question': 'Les retraits sont-ils instantanés ?',
      'answer': 'Les retraits via Mobile Money (Orange, MTN, Moov) sont traités sous 24h. '
          'Les virements bancaires peuvent prendre 2-3 jours ouvrables.',
    },
    {
      'question': 'Y a-t-il des frais de retrait ?',
      'answer': 'Oui : 1% pour Mobile Money et 2% pour virement bancaire. '
          'Les frais sont affichés avant de confirmer votre retrait.',
    },
    {
      'question': 'Comment modifier mon profil ?',
      'answer': 'Allez dans Services → Mon Profil → Modifier. Vous pouvez changer votre nom, '
          'téléphone, adresse et ajouter une photo de profil.',
    },
    {
      'question': 'Que faire si ma poubelle ne se connecte pas ?',
      'answer': '1. Vérifiez que le Bluetooth est activé\n'
          '2. Assurez-vous que la poubelle est allumée\n'
          '3. Rapprochez-vous de la poubelle (max 10m)\n'
          '4. Redémarrez l\'app si nécessaire',
    },
    {
      'question': 'Comment contacter le support ?',
      'answer': 'Vous pouvez nous contacter via :\n'
          '- Email : support@batte.com\n'
          '- Téléphone : +224 XXX XX XX XX\n'
          '- Chat in-app (icône en bas à droite)',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Questions Fréquentes'),
        backgroundColor: BatteColors.primary,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _faqs.length,
        itemBuilder: (context, index) {
          final faq = _faqs[index];
          return _buildFAQCard(faq['question']!, faq['answer']!);
        },
      ),
    );
  }

  Widget _buildFAQCard(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        iconColor: BatteColors.primary,
        collapsedIconColor: BatteColors.mutedForeground,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              answer,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

