import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'storage_service.dart';

/// Service de synthèse vocale et reconnaissance vocale
class VoiceService {
  final FlutterTts _tts = FlutterTts();
  final SpeechToText _stt = SpeechToText();
  
  bool _isInitialized = false;
  bool _isListening = false;
  
  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;
  
  /// Initialise le service vocal
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    try {
      // Configurer TTS
      await _tts.setLanguage(StorageService.getLanguage());
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      
      // Initialiser STT
      _isInitialized = await _stt.initialize(
        onError: (error) => print('Erreur STT: $error'),
        onStatus: (status) => print('Status STT: $status'),
      );
      
      return _isInitialized;
    } catch (e) {
      print('Erreur d\'initialisation du service vocal: $e');
      return false;
    }
  }
  
  /// Change la langue de synthèse vocale
  Future<void> setLanguage(String languageCode) async {
    String ttsLanguage;
    
    switch (languageCode) {
      case 'fr':
        ttsLanguage = 'fr-FR';
        break;
      case 'sus':
        ttsLanguage = 'fr-FR'; // Utiliser français par défaut
        break;
      case 'ff':
        ttsLanguage = 'fr-FR'; // Utiliser français par défaut
        break;
      case 'man':
        ttsLanguage = 'fr-FR'; // Utiliser français par défaut
        break;
      default:
        ttsLanguage = 'fr-FR';
    }
    
    await _tts.setLanguage(ttsLanguage);
  }
  
  /// Lit un texte à voix haute
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    // Vérifier si la voix est activée
    if (!StorageService.getVoiceEnabled()) {
      return;
    }
    
    try {
      await _tts.speak(text);
    } catch (e) {
      print('Erreur de lecture vocale: $e');
    }
  }
  
  /// Arrête la lecture vocale
  Future<void> stop() async {
    await _tts.stop();
  }
  
  /// Démarre l'écoute vocale
  Future<void> startListening({
    required Function(String) onResult,
    Function(String)? onPartialResult,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    if (_isListening) return;
    
    final available = await _stt.initialize();
    if (!available) {
      throw Exception('Reconnaissance vocale non disponible');
    }
    
    _isListening = true;
    
    await _stt.listen(
      onResult: (result) {
        if (result.finalResult) {
          onResult(result.recognizedWords);
          _isListening = false;
        } else {
          onPartialResult?.call(result.recognizedWords);
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: onPartialResult != null,
      cancelOnError: true,
      listenMode: ListenMode.confirmation,
    );
  }
  
  /// Arrête l'écoute vocale
  Future<void> stopListening() async {
    if (_isListening) {
      await _stt.stop();
      _isListening = false;
    }
  }
  
  /// Vérifie si la reconnaissance vocale est disponible
  Future<bool> isAvailable() async {
    return await _stt.initialize();
  }
  
  /// Obtient les langues disponibles pour la reconnaissance vocale
  Future<List<String>> getAvailableLanguages() async {
    if (!_isInitialized) {
      await initialize();
    }
    
    final locales = await _stt.locales();
    return locales.map((locale) => locale.localeId).toList();
  }
  
  /// Traductions multilingues pour les commandes vocales courantes
  Map<String, Map<String, String>> get voiceCommands => {
    'fr': {
      'home': 'accueil',
      'recycling': 'recyclage',
      'budget': 'budget',
      'education': 'éducation',
      'services': 'services',
      'settings': 'paramètres',
      'scan': 'scanner',
      'back': 'retour',
      'yes': 'oui',
      'no': 'non',
    },
    'sus': {
      // Commandes en Soussou (à compléter avec un locuteur natif)
      'home': 'finde',
      'recycling': 'recyclage',
      'budget': 'budget',
      'education': 'karamɔxɔ',
      'services': 'services',
      'settings': 'paramètres',
    },
    'ff': {
      // Commandes en Peulh (à compléter avec un locuteur natif)
      'home': 'galle',
      'recycling': 'recyclage',
      'budget': 'budget',
      'education': 'janngugol',
      'services': 'services',
      'settings': 'paramètres',
    },
    'man': {
      // Commandes en Malinké (à compléter avec un locuteur natif)
      'home': 'so',
      'recycling': 'recyclage',
      'budget': 'budget',
      'education': 'kalanko',
      'services': 'services',
      'settings': 'paramètres',
    },
  };
  
  /// Nettoie les ressources
  void dispose() {
    _tts.stop();
    _stt.stop();
  }
}

