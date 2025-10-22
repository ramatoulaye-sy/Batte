import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

/// Modèle de données pour une transaction
@HiveType(typeId: 2)
class TransactionModel {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String userId;
  
  @HiveField(2)
  final double amount;
  
  @HiveField(3)
  final String type;
  
  @HiveField(4)
  final String? description;
  
  @HiveField(5)
  final DateTime date;
  
  @HiveField(6)
  final String? wasteId;
  
  @HiveField(7)
  final String status;
  
  TransactionModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    this.description,
    DateTime? date,
    this.wasteId,
    this.status = 'completed',
  }) : date = date ?? DateTime.now();
  
  /// Convertit depuis JSON
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      description: json['description'] as String?,
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      wasteId: json['waste_id'] as String?,
      status: json['status'] as String? ?? 'completed',
    );
  }
  
  /// Convertit vers JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'type': type,
      'description': description,
      'date': date.toIso8601String(),
      'waste_id': wasteId,
      'status': status,
    };
  }
  
  /// Crée une copie avec des champs modifiés
  TransactionModel copyWith({
    String? id,
    String? userId,
    double? amount,
    String? type,
    String? description,
    DateTime? date,
    String? wasteId,
    String? status,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      description: description ?? this.description,
      date: date ?? this.date,
      wasteId: wasteId ?? this.wasteId,
      status: status ?? this.status,
    );
  }
  
  /// Obtient le nom du type de transaction
  String get typeName {
    const Map<String, String> typeNames = {
      'recycling': 'Recyclage',
      'withdrawal': 'Retrait',
      'savings': 'Épargne',
      'reward': 'Récompense',
    };
    return typeNames[type] ?? type;
  }
  
  /// Obtient l'icône du type de transaction
  String get typeIcon {
    const Map<String, String> typeIcons = {
      'recycling': '♻️',
      'withdrawal': '💸',
      'savings': '💰',
      'reward': '🎁',
    };
    return typeIcons[type] ?? '💵';
  }
  
  /// Vérifie si c'est un crédit (entrée d'argent)
  bool get isCredit {
    return type == 'recycling' || type == 'reward';
  }
  
  /// Vérifie si c'est un débit (sortie d'argent)
  bool get isDebit {
    return type == 'withdrawal' || type == 'savings';
  }
}

