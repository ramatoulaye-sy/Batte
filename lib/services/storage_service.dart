import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';
import '../models/waste_model.dart';
import '../models/transaction_model.dart';
import '../models/job_model.dart';
import 'outbox_service.dart';

/// Service de stockage local (SharedPreferences + Hive)
class StorageService {
  static SharedPreferences? _prefs;
  static Box<UserModel>? _userBox;
  static Box<WasteModel>? _wasteBox;
  static Box<TransactionModel>? _transactionBox;
  
  /// Initialise le service de stockage
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await Hive.initFlutter();
    
    // Enregistrer les adaptateurs Hive
    // Note: Les adaptateurs sont générés via build_runner (fichiers *.g.dart)
    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(WasteModelAdapter());
    Hive.registerAdapter(TransactionModelAdapter());
    
    // Ouvrir les boxes
    _userBox = await Hive.openBox<UserModel>('users');
    _wasteBox = await Hive.openBox<WasteModel>('wastes');
    _transactionBox = await Hive.openBox<TransactionModel>('transactions');

    // Outbox générique
    await OutboxService.init();
  }
  
  // ===== Token Management =====
  
  static Future<void> saveAccessToken(String token) async {
    await _prefs?.setString(AppConstants.keyAccessToken, token);
  }
  
  static String? getAccessToken() {
    return _prefs?.getString(AppConstants.keyAccessToken);
  }
  
  static Future<void> saveRefreshToken(String token) async {
    await _prefs?.setString(AppConstants.keyRefreshToken, token);
  }
  
  static String? getRefreshToken() {
    return _prefs?.getString(AppConstants.keyRefreshToken);
  }
  
  static Future<void> clearTokens() async {
    await _prefs?.remove(AppConstants.keyAccessToken);
    await _prefs?.remove(AppConstants.keyRefreshToken);
  }
  
  // ===== User Management =====
  
  static Future<void> saveUser(UserModel user) async {
    await _userBox?.put('current_user', user);
    await _prefs?.setString(AppConstants.keyUserId, user.id);
  }
  
  static UserModel? getUser() {
    return _userBox?.get('current_user');
  }
  
  static Future<void> clearUser() async {
    await _userBox?.delete('current_user');
    await _prefs?.remove(AppConstants.keyUserId);
  }
  
  // ===== Pending User Data (for signup flow) =====
  
  static Future<void> savePendingUserName(String name) async {
    await _prefs?.setString('pending_user_name', name);
  }
  
  static Future<String?> getPendingUserName() async {
    return _prefs?.getString('pending_user_name');
  }
  
  static Future<void> savePendingUserPhone(String phone) async {
    await _prefs?.setString('pending_user_phone', phone);
  }
  
  static Future<String?> getPendingUserPhone() async {
    return _prefs?.getString('pending_user_phone');
  }
  
  static Future<void> clearPendingUserData() async {
    await _prefs?.remove('pending_user_name');
    await _prefs?.remove('pending_user_phone');
  }
  
  // ===== Settings =====
  
  static Future<void> saveLanguage(String language) async {
    await _prefs?.setString(AppConstants.keyLanguage, language);
  }
  
  static String getLanguage() {
    return _prefs?.getString(AppConstants.keyLanguage) ?? 'fr';
  }
  
  static Future<void> saveVoiceEnabled(bool enabled) async {
    await _prefs?.setBool(AppConstants.keyVoiceEnabled, enabled);
  }
  
  static bool getVoiceEnabled() {
    return _prefs?.getBool(AppConstants.keyVoiceEnabled) ?? false;
  }
  
  static Future<void> setFirstLaunch(bool value) async {
    await _prefs?.setBool(AppConstants.keyFirstLaunch, value);
  }
  
  static bool isFirstLaunch() {
    return _prefs?.getBool(AppConstants.keyFirstLaunch) ?? true;
  }
  
  static Future<void> saveBinDeviceId(String deviceId) async {
    await _prefs?.setString(AppConstants.keyBinDeviceId, deviceId);
  }
  
  static String? getBinDeviceId() {
    return _prefs?.getString(AppConstants.keyBinDeviceId);
  }
  
  // ===== Waste Management (Offline) =====
  
  static Future<void> saveWaste(WasteModel waste) async {
    await _wasteBox?.put(waste.id, waste);
  }
  
  static List<WasteModel> getWastes() {
    return _wasteBox?.values.toList() ?? [];
  }
  
  static List<WasteModel> getUnsyncedWastes() {
    return _wasteBox?.values.where((w) => !w.synced).toList() ?? [];
  }
  
  static Future<void> clearWastes() async {
    await _wasteBox?.clear();
  }
  
  static Future<void> deleteWaste(String wasteId) async {
    await _wasteBox?.delete(wasteId);
  }
  
  // ===== Transaction Management (Offline) =====
  
  static Future<void> saveTransaction(TransactionModel transaction) async {
    await _transactionBox?.put(transaction.id, transaction);
  }
  
  static List<TransactionModel> getTransactions() {
    return _transactionBox?.values.toList() ?? [];
  }
  
  static Future<void> clearTransactions() async {
    await _transactionBox?.clear();
  }
  
  static Future<void> deleteTransaction(String transactionId) async {
    await _transactionBox?.delete(transactionId);
  }
  
  // ===== Services (Jobs) - JSON in SharedPreferences =====
  static const String _jobsKey = 'batte_jobs_v1';

  static List<JobModel> getJobs() {
    try {
      final jsonString = _prefs?.getString(_jobsKey);
      if (jsonString == null || jsonString.isEmpty) return [];
      final List<dynamic> raw = List<dynamic>.from((json.decode(jsonString) as List));
      return raw.map((e) => JobModel.fromJson(Map<String, dynamic>.from(e))).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveJob(JobModel job) async {
    final current = getJobs();
    final idx = current.indexWhere((j) => j.id == job.id);
    if (idx >= 0) {
      current[idx] = job;
    } else {
      current.insert(0, job);
    }
    final payload = json.encode(current.map((e) => e.toJson()).toList());
    await _prefs?.setString(_jobsKey, payload);
  }

  static Future<void> deleteJob(String jobId) async {
    final current = getJobs();
    current.removeWhere((j) => j.id == jobId);
    final payload = json.encode(current.map((e) => e.toJson()).toList());
    await _prefs?.setString(_jobsKey, payload);
  }

  static Future<void> clearJobs() async {
    await _prefs?.remove(_jobsKey);
  }
  
  // ===== Clear All Data =====
  
  static Future<void> clearAll() async {
    await clearTokens();
    await clearUser();
    await clearWastes();
    await clearTransactions();
    await _prefs?.clear();
  }
}

