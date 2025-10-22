/// Modèle de données pour les offres d'emploi/services
class JobModel {
  final String id;
  final String title;
  final String description;
  final String type; // 'offer' (proposition) ou 'request' (demande)
  final String category;
  final String? location;
  final double? salary;
  final String userId;
  final String userName;
  final String? userPhone;
  final String? userPhoto;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final String status; // 'active', 'closed', 'expired'
  final List<String>? skills;
  
  JobModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    this.location,
    this.salary,
    required this.userId,
    required this.userName,
    this.userPhone,
    this.userPhoto,
    DateTime? createdAt,
    this.expiresAt,
    this.status = 'active',
    this.skills,
  }) : createdAt = createdAt ?? DateTime.now();
  
  /// Convertit depuis JSON
  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      category: json['category'] as String,
      location: json['location'] as String?,
      salary: json['salary'] != null
          ? (json['salary'] as num).toDouble()
          : null,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      userPhone: json['user_phone'] as String?,
      userPhoto: json['user_photo'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : null,
      status: json['status'] as String? ?? 'active',
      skills: json['skills'] != null
          ? List<String>.from(json['skills'])
          : null,
    );
  }
  
  /// Convertit vers JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'category': category,
      'location': location,
      'salary': salary,
      'user_id': userId,
      'user_name': userName,
      'user_phone': userPhone,
      'user_photo': userPhoto,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'status': status,
      'skills': skills,
    };
  }
  
  /// Crée une copie avec des champs modifiés
  JobModel copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    String? category,
    String? location,
    double? salary,
    String? userId,
    String? userName,
    String? userPhone,
    String? userPhoto,
    DateTime? createdAt,
    DateTime? expiresAt,
    String? status,
    List<String>? skills,
  }) {
    return JobModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      category: category ?? this.category,
      location: location ?? this.location,
      salary: salary ?? this.salary,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      userPhoto: userPhoto ?? this.userPhoto,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
      skills: skills ?? this.skills,
    );
  }
  
  /// Obtient l'icône de la catégorie
  String get categoryIcon {
    const Map<String, String> categoryIcons = {
      'cleaning': '🧹',
      'cooking': '🍳',
      'sewing': '🪡',
      'education': '📚',
      'technology': '💻',
      'agriculture': '🌾',
      'commerce': '🛒',
      'other': '👩🏽‍🔧',
    };
    return categoryIcons[category] ?? '👩🏽‍🔧';
  }
  
  /// Vérifie si l'offre est expirée
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }
}

