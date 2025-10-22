import 'package:flutter/material.dart';
import '../models/job_model.dart';
import '../services/storage_service.dart';
import '../services/supabase_service.dart';
import '../services/connectivity_service.dart';
import '../services/outbox_service.dart';
import '../models/outbox_item.dart';
import '../services/outbox_types.dart';
import '../core/utils/helpers.dart';

class ServicesProvider with ChangeNotifier {
  List<JobModel> _jobs = [];
  bool _isLoading = false;
  String? _error;

  List<JobModel> get jobs => _jobs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadJobs() async {
    _isLoading = true;
    _error = null;
    try {
      // 1. Charger d'abord depuis le stockage local
      _jobs = StorageService.getJobs();
      notifyListeners(); // Afficher immédiatement
      
      // 2. Essayer de synchroniser avec Supabase
      try {
        final serverJobs = await SupabaseService.searchServices(limit: 50);
        final localJobsMap = <String, JobModel>{};
        
        // Indexer les jobs locaux
        for (var job in _jobs) {
          localJobsMap[job.id] = job;
        }
        
        // Ajouter les jobs serveur qui ne sont pas déjà locaux
        for (var serverJob in serverJobs) {
          final jobId = serverJob['id'] as String;
          if (!localJobsMap.containsKey(jobId)) {
            final job = JobModel.fromJson({
              'id': jobId,
              'title': serverJob['title'],
              'description': serverJob['description'],
              'type': 'offer', // Les jobs serveur sont des offres
              'category': serverJob['category'],
              'location': serverJob['location'],
              'salary': serverJob['price'],
              'user_id': serverJob['provider']['user_id'],
              'user_name': serverJob['provider']['bio'] ?? 'Prestataire',
              'user_phone': null,
              'created_at': serverJob['created_at'],
              'status': 'active',
            });
            localJobsMap[jobId] = job;
            await StorageService.saveJob(job);
          }
        }
        
        // Mettre à jour la liste
        _jobs = localJobsMap.values.toList();
        _jobs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } catch (serverError) {
        print('Erreur de synchronisation serveur: $serverError');
        // Garder les données locales
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du chargement des services';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createOffer({
    required String title,
    required String description,
    required String category,
    double? price,
    String? location,
    List<String>? skills,
    required String userId,
    required String userName,
    String? userPhone,
  }) async {
    try {
      final job = JobModel(
        id: Helpers.generateUniqueId(),
        title: title,
        description: description,
        type: 'offer',
        category: category,
        location: location,
        salary: price,
        userId: userId,
        userName: userName,
        userPhone: userPhone,
        skills: skills,
      );
      
      // Ajouter immédiatement localement
      _jobs.insert(0, job);
      await StorageService.saveJob(job);
      notifyListeners();
      
      // Synchroniser en arrière-plan
      _syncOfferInBackground(job);
      
      return true;
    } catch (e) {
      _error = 'Erreur lors de la création de l\'offre';
      notifyListeners();
      return false;
    }
  }

  /// Synchronise une offre en arrière-plan
  Future<void> _syncOfferInBackground(JobModel job) async {
    try {
      final connectivity = ConnectivityService();
      if (!connectivity.isOnline) {
        // Mettre en file d'attente pour synchronisation ultérieure
        await OutboxService.enqueue(
          OutboxItem(
            id: 'offer_${job.id}',
            type: OutboxTypes.serviceOfferCreate,
            payload: job.toJson(),
          ),
        );
        return;
      }

      // Synchroniser avec Supabase
      final result = await SupabaseService.createServiceOffer(
        title: job.title,
        description: job.description,
        category: job.category,
        price: job.salary,
        location: job.location,
      );

      if (result['success'] == true) {
        // Marquer comme synchronisé
        final syncedJob = job.copyWith(
          id: result['offer_id'],
          status: 'active',
        );
        
        final index = _jobs.indexWhere((j) => j.id == job.id);
        if (index != -1) {
          _jobs[index] = syncedJob;
          await StorageService.saveJob(syncedJob);
          notifyListeners();
        }
      }
    } catch (e) {
      print('Erreur de synchronisation de l\'offre: $e');
    }
  }

  Future<bool> createRequest({
    required String title,
    required String description,
    required String category,
    double? budget,
    String? location,
    List<String>? requirements,
    required String userId,
    required String userName,
    String? userPhone,
  }) async {
    try {
      final job = JobModel(
        id: Helpers.generateUniqueId(),
        title: title,
        description: description,
        type: 'request',
        category: category,
        location: location,
        salary: budget,
        userId: userId,
        userName: userName,
        userPhone: userPhone,
        skills: requirements,
      );
      _jobs.insert(0, job);
      await StorageService.saveJob(job);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erreur lors de la création de la demande';
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteJob(String jobId) async {
    _jobs.removeWhere((j) => j.id == jobId);
    await StorageService.deleteJob(jobId);
    notifyListeners();
  }
}


