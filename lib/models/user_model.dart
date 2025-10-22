import 'package:hive/hive.dart';

part 'user_model.g.dart';

/// Modèle de données pour l'utilisateur
@HiveType(typeId: 0)
class UserModel {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String phone;
  
  @HiveField(2)
  final String? name;
  
  @HiveField(3)
  final String? email;
  
  @HiveField(4)
  final String role;
  
  @HiveField(5)
  final double balance;
  
  @HiveField(6)
  final String language;
  
  @HiveField(7)
  final bool voiceEnabled;
  
  @HiveField(8)
  final double totalWeight;
  
  @HiveField(9)
  final int ecoScore;
  
  @HiveField(10)
  final String? profilePicture;
  
  @HiveField(11)
  final DateTime createdAt;
  
  @HiveField(12)
  final DateTime updatedAt;
  
  @HiveField(13)
  final String? avatarUrl;
  
  @HiveField(14)
  final int level;
  
  @HiveField(15)
  final String? city;
  
  @HiveField(16)
  final String? address;
  
  @HiveField(17)
  final String? bio;
  
  UserModel({
    required this.id,
    required this.phone,
    this.name,
    this.email,
    this.role = 'user',
    this.balance = 0,
    this.language = 'fr',
    this.voiceEnabled = false,
    this.totalWeight = 0,
    this.ecoScore = 0,
    this.profilePicture,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.avatarUrl,
    this.level = 1,
    this.city,
    this.address,
    this.bio,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();
  
  /// Convertit depuis JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      // En mode auth par email, le téléphone peut être null => fallback vide
      phone: (json['phone'] as String?) ?? '',
      name: json['name'] as String?,
      email: json['email'] as String?,
      role: json['role'] as String? ?? 'user',
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      language: json['language'] as String? ?? 'fr',
      voiceEnabled: json['voice_enabled'] as bool? ?? false,
      totalWeight: (json['total_weight'] as num?)?.toDouble() ?? 0,
      ecoScore: json['eco_score'] as int? ?? 0,
      profilePicture: json['profile_picture'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      avatarUrl: json['avatar_url'] as String?,
      level: json['level'] as int? ?? 1,
      city: json['city'] as String?,
      address: json['address'] as String?,
      bio: json['bio'] as String?,
    );
  }
  
  /// Convertit vers JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'name': name,
      'email': email,
      'role': role,
      'balance': balance,
      'language': language,
      'voice_enabled': voiceEnabled,
      'total_weight': totalWeight,
      'eco_score': ecoScore,
      'profile_picture': profilePicture,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'avatar_url': avatarUrl,
      'level': level,
      'city': city,
      'address': address,
      'bio': bio,
    };
  }
  
  /// Crée une copie avec des champs modifiés
  UserModel copyWith({
    String? id,
    String? phone,
    String? name,
    String? email,
    String? role,
    double? balance,
    String? language,
    bool? voiceEnabled,
    double? totalWeight,
    int? ecoScore,
    String? profilePicture,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? avatarUrl,
    int? level,
    String? city,
    String? address,
    String? bio,
  }) {
    return UserModel(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      balance: balance ?? this.balance,
      language: language ?? this.language,
      voiceEnabled: voiceEnabled ?? this.voiceEnabled,
      totalWeight: totalWeight ?? this.totalWeight,
      ecoScore: ecoScore ?? this.ecoScore,
      profilePicture: profilePicture ?? this.profilePicture,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      level: level ?? this.level,
      city: city ?? this.city,
      address: address ?? this.address,
      bio: bio ?? this.bio,
    );
  }
}

