import 'package:drift/drift.dart';

class Voices extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get provider => text().withLength(min: 1, max: 50)();
  TextColumn get providerVoiceId => text().withLength(min: 1, max: 255)();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get description => text().nullable()();
  TextColumn get language => text().withLength(min: 1, max: 10)();
  TextColumn get gender => text().withLength(min: 1, max: 20)();
  TextColumn get accent => text().nullable()();
  BoolColumn get isCloned => boolean().withDefault(const Constant(false))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class Voice {
  final int id;
  final String provider;
  final String providerVoiceId;
  final String name;
  final String? description;
  final String language;
  final String gender;
  final String? accent;
  final bool isCloned;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Voice({
    required this.id,
    required this.provider,
    required this.providerVoiceId,
    required this.name,
    this.description,
    required this.language,
    required this.gender,
    this.accent,
    this.isCloned = false,
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Voice copyWith({
    int? id,
    String? provider,
    String? providerVoiceId,
    String? name,
    String? description,
    String? language,
    String? gender,
    String? accent,
    bool? isCloned,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Voice(
      id: id ?? this.id,
      provider: provider ?? this.provider,
      providerVoiceId: providerVoiceId ?? this.providerVoiceId,
      name: name ?? this.name,
      description: description ?? this.description,
      language: language ?? this.language,
      gender: gender ?? this.gender,
      accent: accent ?? this.accent,
      isCloned: isCloned ?? this.isCloned,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Voice.fromJson(Map<String, dynamic> json) {
    return Voice(
      id: json['id'] as int,
      provider: json['provider'] as String,
      providerVoiceId: json['providerVoiceId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      language: json['language'] as String,
      gender: json['gender'] as String,
      accent: json['accent'] as String?,
      isCloned: json['isCloned'] as bool? ?? false,
      isFavorite: json['isFavorite'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider': provider,
      'providerVoiceId': providerVoiceId,
      'name': name,
      'description': description,
      'language': language,
      'gender': gender,
      'accent': accent,
      'isCloned': isCloned,
      'isFavorite': isFavorite,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
