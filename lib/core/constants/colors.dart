import 'package:flutter/material.dart';

/// Palette de couleurs Battè
/// Définit toutes les couleurs utilisées dans l'application
class BatteColors {
  // Couleurs Principales de la Marque (Design UI/UX 2024)
  static const Color primary = Color(0xFF38761D); // Vert profond (stabilité, nature)
  static const Color secondary = Color(0xFFF7E2AC); // Jaune or (récompenses, motivation)
  static const Color lightGreen = Color(0xFFC8E6C9); // Vert clair (fraîcheur)
  static const Color softGreen = Color(0xFFDCEEDD); // Vert très clair (douceur)
  static const Color cardBackground = Color(0xFFC8E6C9); // Vert clair (legacy)
  static const Color purple = Color(0xFF8B5CF6); // Violet
  static const Color gold = Color(0xFFF7E2AC); // Accent gold (alias)
  
  // Couleurs Système
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color foreground = Color(0xFF252525);
  
  // Couleurs UI/Interface
  static const Color inputBackground = Color(0xFFF3F3F5);
  static const Color muted = Color(0xFFECECF0);
  static const Color mutedForeground = Color(0xFF717182);
  static const Color switchBackground = Color(0xFFCBCED4);
  static const Color accent = Color(0xFFE9EBEF);
  static const Color border = Color(0x1A000000);
  
  // Couleurs Fonctionnelles
  static const Color destructive = Color(0xFFD4183D);
  static const Color destructiveForeground = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF38761D);
  static const Color warning = Color(0xFFFBC02D);
  static const Color info = Color(0xFF8B5CF6);
  
  // Couleurs Charts/Graphiques
  static const Color chart1 = Color(0xFFE67E22);
  static const Color chart2 = Color(0xFF3498DB);
  static const Color chart3 = Color(0xFF2C3E50);
  static const Color chart4 = Color(0xFFBDE55A);
  static const Color chart5 = Color(0xFFF1C40F);
  
  // Gradients (Design moderne 2024)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF4A8F2A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFF7E2AC), Color(0xFFFFE88C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient balanceCardGradient = LinearGradient(
    colors: [primary, Color(0xFF2D5F17)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient ecoCardGradient = LinearGradient(
    colors: [lightGreen, softGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

