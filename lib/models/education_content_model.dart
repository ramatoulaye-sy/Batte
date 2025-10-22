/// Modèle de données pour le contenu éducatif
class EducationContentModel {
  final String id;
  final String title;
  final String description;
  final String type; // 'video', 'audio', 'quiz'
  final String? url;
  final String? thumbnailUrl;
  final int points;
  final int duration; // En secondes
  final String language;
  final List<String>? tags;
  final DateTime createdAt;
  final bool completed;
  
  EducationContentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.url,
    this.thumbnailUrl,
    this.points = 0,
    this.duration = 0,
    this.language = 'fr',
    this.tags,
    DateTime? createdAt,
    this.completed = false,
  }) : createdAt = createdAt ?? DateTime.now();
  
  /// Convertit depuis JSON
  factory EducationContentModel.fromJson(Map<String, dynamic> json) {
    return EducationContentModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      url: json['url'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      points: json['points'] as int? ?? 0,
      duration: json['duration'] as int? ?? 0,
      language: json['language'] as String? ?? 'fr',
      tags: json['tags'] != null
          ? List<String>.from(json['tags'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      completed: json['completed'] as bool? ?? false,
    );
  }
  
  /// Convertit vers JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'url': url,
      'thumbnail_url': thumbnailUrl,
      'points': points,
      'duration': duration,
      'language': language,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
      'completed': completed,
    };
  }
  
  /// Crée une copie avec des champs modifiés
  EducationContentModel copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    String? url,
    String? thumbnailUrl,
    int? points,
    int? duration,
    String? language,
    List<String>? tags,
    DateTime? createdAt,
    bool? completed,
  }) {
    return EducationContentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      url: url ?? this.url,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      points: points ?? this.points,
      duration: duration ?? this.duration,
      language: language ?? this.language,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      completed: completed ?? this.completed,
    );
  }
  
  /// Obtient l'icône du type de contenu
  String get typeIcon {
    const Map<String, String> typeIcons = {
      'video': '🎥',
      'audio': '🎧',
      'quiz': '📝',
    };
    return typeIcons[type] ?? '📚';
  }
  
  /// Formate la durée
  String get formattedDuration {
    final minutes = (duration / 60).floor();
    final seconds = duration % 60;
    if (minutes > 0) {
      return '$minutes min ${seconds}s';
    }
    return '${seconds}s';
  }
}

