import 'package:hive/hive.dart';

part 'waste_model.g.dart';

/// Modèle de données pour un déchet recyclé
@HiveType(typeId: 1)
class WasteModel {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String userId;
  
  @HiveField(2)
  final String type;
  
  @HiveField(3)
  final double weight;
  
  @HiveField(4)
  final double value;
  
  @HiveField(5)
  final DateTime date;
  
  @HiveField(6)
  final String? binDeviceId;
  
  @HiveField(7)
  final bool synced;
  
  @HiveField(8)
  final String? notes;
  
  WasteModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.weight,
    required this.value,
    DateTime? date,
    this.binDeviceId,
    this.synced = false,
    this.notes,
  }) : date = date ?? DateTime.now();
  
  /// Convertit depuis JSON
  factory WasteModel.fromJson(Map<String, dynamic> json) {
    return WasteModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: json['type'] as String,
      weight: (json['weight'] as num).toDouble(),
      value: (json['value'] as num).toDouble(),
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      binDeviceId: json['bin_device_id'] as String?,
      synced: json['synced'] as bool? ?? true,
      notes: json['notes'] as String?,
    );
  }
  
  /// Convertit vers JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'weight': weight,
      'value': value,
      'date': date.toIso8601String(),
      'bin_device_id': binDeviceId,
      'synced': synced,
      'notes': notes,
    };
  }
  
  /// Crée une copie avec des champs modifiés
  WasteModel copyWith({
    String? id,
    String? userId,
    String? type,
    double? weight,
    double? value,
    DateTime? date,
    String? binDeviceId,
    bool? synced,
    String? notes,
  }) {
    return WasteModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      weight: weight ?? this.weight,
      value: value ?? this.value,
      date: date ?? this.date,
      binDeviceId: binDeviceId ?? this.binDeviceId,
      synced: synced ?? this.synced,
      notes: notes ?? this.notes,
    );
  }
  
  /// Obtient le nom du type de déchet
  String get typeName {
    const Map<String, String> typeNames = {
      'plastic': 'Plastique',
      'paper': 'Papier',
      'metal': 'Métal',
      'glass': 'Verre',
      'organic': 'Organique',
    };
    return typeNames[type] ?? type;
  }
  
  /// Obtient l'icône du type de déchet
  String get typeIcon {
    const Map<String, String> typeIcons = {
      'plastic': '♻️',
      'paper': '📄',
      'metal': '🔩',
      'glass': '🍾',
      'organic': '🍂',
    };
    return typeIcons[type] ?? '📦';
  }
}

