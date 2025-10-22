import 'package:flutter/material.dart';
import '../models/education_content_model.dart';
import '../services/supabase_service.dart';

/// Provider pour la gestion du contenu éducatif
class EducationProvider with ChangeNotifier {
  
  List<EducationContentModel> _contents = [];
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _progress;
  
  List<EducationContentModel> get contents => _contents;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get progress => _progress;
  
  /// Récupère le contenu éducatif
  Future<void> fetchContent({String? type, String? language}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final data = await SupabaseService.getEducationContent(
        type: type,
        language: language,
      );
      _contents = data.map((json) => EducationContentModel.fromJson(json)).toList();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur de chargement du contenu';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Récupère la progression de l'utilisateur
  Future<void> fetchProgress() async {
    try {
      // TODO: Implémenter getEducationProgress
      _progress = {};
      notifyListeners();
    } catch (e) {
      print('Erreur de chargement de la progression: $e');
    }
  }
  
  /// Récupère un quiz
  Future<Map<String, dynamic>?> getQuiz(String contentId) async {
    try {
      // TODO: Implémenter getQuiz
      return {};
    } catch (e) {
      _error = 'Erreur de chargement du quiz';
      notifyListeners();
      return null;
    }
  }
  
  /// Soumet les réponses d'un quiz
  Future<Map<String, dynamic>?> submitQuiz(
    String contentId,
    Map<String, dynamic> answers,
  ) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // TODO: Implémenter submitQuizAnswer
      await SupabaseService.saveEducationProgress(contentId: contentId, completed: true);
      final result = <String, dynamic>{};
      
      _isLoading = false;
      notifyListeners();
      
      // Rafraîchir la progression
      fetchProgress();
      
      return result;
    } catch (e) {
      _error = 'Erreur de soumission du quiz';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
  
  /// Marque un contenu comme complété
  Future<void> markAsCompleted(String contentId) async {
    final index = _contents.indexWhere((c) => c.id == contentId);
    if (index != -1) {
      _contents[index] = _contents[index].copyWith(completed: true);
      notifyListeners();
    }
    
    // Rafraîchir la progression
    fetchProgress();
  }
  
  /// Obtient le contenu par type
  List<EducationContentModel> getContentByType(String type) {
    return _contents.where((c) => c.type == type).toList();
  }
  
  /// Obtient le total des points gagnés
  int get totalPoints {
    return _contents
        .where((c) => c.completed)
        .fold(0, (sum, c) => sum + c.points);
  }
  
  /// Obtient le pourcentage de progression
  double get progressPercentage {
    if (_contents.isEmpty) return 0;
    final completed = _contents.where((c) => c.completed).length;
    return (completed / _contents.length) * 100;
  }
  
  /// Nettoie l'erreur
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

