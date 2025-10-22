import 'package:intl/intl.dart';

/// Fonctions d'aide générales
class Helpers {
  /// Formate un montant en devise GNF
  static String formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0', 'fr_FR');
    return '${formatter.format(amount)} GNF';
  }
  
  /// Formate une date
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
  
  /// Formate une date avec l'heure
  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }
  
  /// Formate une date relative (il y a X jours)
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return 'Il y a $years ${years > 1 ? "ans" : "an"}';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return 'Il y a $months mois';
    } else if (difference.inDays > 0) {
      return 'Il y a ${difference.inDays} ${difference.inDays > 1 ? "jours" : "jour"}';
    } else if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours} ${difference.inHours > 1 ? "heures" : "heure"}';
    } else if (difference.inMinutes > 0) {
      return 'Il y a ${difference.inMinutes} ${difference.inMinutes > 1 ? "minutes" : "minute"}';
    } else {
      return "À l'instant";
    }
  }
  
  /// Formate un poids (en kg)
  static String formatWeight(double weight) {
    if (weight >= 1000) {
      return '${(weight / 1000).toStringAsFixed(2)} tonnes';
    } else if (weight >= 1) {
      return '${weight.toStringAsFixed(2)} kg';
    } else {
      return '${(weight * 1000).toStringAsFixed(0)} g';
    }
  }
  
  /// Nettoie un numéro de téléphone
  static String cleanPhoneNumber(String phone) {
    String cleaned = phone.replaceAll(' ', '').replaceAll('-', '');
    if (cleaned.startsWith('+224')) {
      return cleaned;
    } else if (cleaned.startsWith('224')) {
      return '+$cleaned';
    } else if (cleaned.length == 9) {
      return '+224$cleaned';
    }
    return cleaned;
  }
  
  /// Calcule le score écologique basé sur le poids recyclé
  static int calculateEcoScore(double totalWeight) {
    // 1 kg = 10 points
    return (totalWeight * 10).toInt();
  }
  
  /// Calcule la valeur monétaire basée sur le type et le poids
  static double calculateWasteValue(String wasteType, double weight) {
    const Map<String, double> pricePerKg = {
      'plastic': 1500,
      'paper': 800,
      'metal': 2000,
      'glass': 500,
      'organic': 300,
    };
    
    return (pricePerKg[wasteType] ?? 0) * weight;
  }
  
  /// Vérifie si l'appareil est en ligne
  static Future<bool> isOnline() async {
    // Cette fonction sera implémentée avec connectivity_plus
    return true;
  }
  
  /// Génère un ID unique
  static String generateUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}

