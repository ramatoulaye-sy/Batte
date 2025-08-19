// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:batte/main.dart';

void main() {
  testWidgets('Batte app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BatteApp());

    // Verify that our app starts with the home page
    expect(find.text('Accueil'), findsOneWidget);
    expect(find.text('Monétisation'), findsOneWidget);
    expect(find.text('Pour Moi'), findsOneWidget);
    expect(find.text('Budget'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
  });

  testWidgets('Navigation between tabs', (WidgetTester tester) async {
    await tester.pumpWidget(const BatteApp());

    // Test navigation to Monetization tab
    await tester.tap(find.text('Monétisation'));
    await tester.pump();
    expect(find.text('Monétisation des Déchets'), findsOneWidget);

    // Test navigation to Pour Moi tab
    await tester.tap(find.text('Pour Moi'));
    await tester.pump();
    expect(find.text('Pour Moi'), findsOneWidget);

    // Test navigation to Budget tab
    await tester.tap(find.text('Budget'));
    await tester.pump();
    expect(find.text('Mon Budget'), findsOneWidget);

    // Test navigation to Profile tab
    await tester.tap(find.text('Profil'));
    await tester.pump();
    expect(find.text('Mon Profil'), findsOneWidget);

    // Return to home
    await tester.tap(find.text('Accueil'));
    await tester.pump();
    expect(find.text('Accueil'), findsOneWidget);
  });

  testWidgets('Home page elements', (WidgetTester tester) async {
    await tester.pumpWidget(const BatteApp());

    // Verify main elements on home page
    expect(find.text('Bonjour !'), findsOneWidget);
    expect(find.text('Actions Rapides'), findsOneWidget);
    expect(find.text('Scanner QR'), findsOneWidget);
    expect(find.text('Connecter Bluetooth'), findsOneWidget);
    expect(find.text('Saisie Manuelle'), findsOneWidget);
    expect(find.text('Historique'), findsOneWidget);
  });
}
