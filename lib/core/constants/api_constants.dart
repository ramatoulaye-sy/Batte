import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Constantes API pour les endpoints backend
class ApiConstants {
  // Base URL (chargée depuis le fichier .env)
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000/api';
  
  // Authentication Endpoints
  static const String authSignup = '/auth/signup';
  static const String authLogin = '/auth/login';
  static const String authVerifyOtp = '/auth/verify-otp';
  static const String authResendOtp = '/auth/resend-otp';
  static const String authLogout = '/auth/logout';
  static const String authRefreshToken = '/auth/refresh';
  
  // User Endpoints
  static const String userProfile = '/users/profile';
  static const String userUpdate = '/users/update';
  static const String userBalance = '/users/balance';
  
  // Waste/Recycling Endpoints
  static const String wastesCreate = '/wastes';
  static const String wastesHistory = '/wastes/history';
  static const String wastesStats = '/wastes/stats';
  static const String wastesTypes = '/wastes/types';
  
  // Transactions Endpoints
  static const String transactions = '/transactions';
  static const String transactionsHistory = '/transactions/history';
  static const String transactionsStats = '/transactions/stats';
  
  // Education Endpoints
  static const String educationContent = '/education';
  static const String educationQuiz = '/education/quiz';
  static const String educationProgress = '/education/progress';
  
  // Jobs/Services Endpoints
  static const String jobs = '/jobs';
  static const String jobsCreate = '/jobs/create';
  static const String jobsApply = '/jobs/apply';
  
  // Collectors Endpoints
  static const String collectors = '/collectors';
  static const String collectorsNearby = '/collectors/nearby';
  
  // Notifications Endpoints
  static const String notifications = '/notifications';
  static const String notificationsMarkRead = '/notifications/mark-read';
  
  // Bluetooth/IoT Endpoints
  static const String iotSync = '/iot/sync';
  static const String iotRegister = '/iot/register';
  
  // Headers
  static const String contentTypeJson = 'application/json';
  static const String authorizationHeader = 'Authorization';
  
  // Timeout
  static const int timeoutSeconds = 30;
}

