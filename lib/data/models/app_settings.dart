import 'package:drift/drift.dart';

import '../../core/constants/app_constants.dart';
import '../datasources/local/app_database.dart';

/// Sentinel telling `copyWith` to keep the current value.
const Object _unchanged = Object();

class AppSettingsTable extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();

  @override
  Set<Column<Object>> get primaryKey => {id};

  TextColumn get themeMode => text().withDefault(const Constant('system'))();
  IntColumn get defaultVoiceId => integer().nullable()();
  RealColumn get defaultSpeed => real().withDefault(const Constant(1.0))();
  TextColumn get defaultFormat => text().withDefault(const Constant('mp3'))();
  BoolColumn get autoNormalize => boolean().withDefault(const Constant(true))();
  BoolColumn get autoSplit => boolean().withDefault(const Constant(true))();
  IntColumn get warningThreshold =>
      integer().withDefault(const Constant(1000))();
  TextColumn get ttsProvider => text().withDefault(const Constant('google'))();

  /// Base URL of the VietVoice backend. Null means "use the compiled default".
  TextColumn get backendUrl => text().nullable()();
}

class AppSettings {
  final int id;
  final String themeMode;
  final int? defaultVoiceId;
  final double defaultSpeed;
  final String defaultFormat;
  final bool autoNormalize;
  final bool autoSplit;
  final int warningThreshold;
  final String ttsProvider;
  final String? backendUrl;

  const AppSettings({
    this.id = 1,
    this.themeMode = 'system',
    this.defaultVoiceId,
    this.defaultSpeed = 1.0,
    this.defaultFormat = 'mp3',
    this.autoNormalize = true,
    this.autoSplit = true,
    this.warningThreshold = 1000,
    this.ttsProvider = AppConstants.defaultTtsProvider,
    this.backendUrl,
  });

  AppSettings copyWith({
    int? id,
    String? themeMode,
    int? defaultVoiceId,
    double? defaultSpeed,
    String? defaultFormat,
    bool? autoNormalize,
    bool? autoSplit,
    int? warningThreshold,
    String? ttsProvider,
    // `null` here means "clear the stored address", so it needs a sentinel:
    // without one, copyWith could never go back to the compiled default.
    Object? backendUrl = _unchanged,
  }) {
    return AppSettings(
      id: id ?? this.id,
      themeMode: themeMode ?? this.themeMode,
      defaultVoiceId: defaultVoiceId ?? this.defaultVoiceId,
      defaultSpeed: defaultSpeed ?? this.defaultSpeed,
      defaultFormat: defaultFormat ?? this.defaultFormat,
      autoNormalize: autoNormalize ?? this.autoNormalize,
      autoSplit: autoSplit ?? this.autoSplit,
      warningThreshold: warningThreshold ?? this.warningThreshold,
      ttsProvider: ttsProvider ?? this.ttsProvider,
      backendUrl: identical(backendUrl, _unchanged)
          ? this.backendUrl
          : backendUrl as String?,
    );
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      id: json['id'] as int? ?? 1,
      themeMode: json['themeMode'] as String? ?? 'system',
      defaultVoiceId: json['defaultVoiceId'] as int?,
      defaultSpeed: (json['defaultSpeed'] as num?)?.toDouble() ?? 1.0,
      defaultFormat: json['defaultFormat'] as String? ?? 'mp3',
      autoNormalize: json['autoNormalize'] as bool? ?? true,
      autoSplit: json['autoSplit'] as bool? ?? true,
      warningThreshold: json['warningThreshold'] as int? ?? 1000,
      ttsProvider:
          json['ttsProvider'] as String? ?? AppConstants.defaultTtsProvider,
      backendUrl: json['backendUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'themeMode': themeMode,
      'defaultVoiceId': defaultVoiceId,
      'defaultSpeed': defaultSpeed,
      'defaultFormat': defaultFormat,
      'autoNormalize': autoNormalize,
      'autoSplit': autoSplit,
      'warningThreshold': warningThreshold,
      'ttsProvider': ttsProvider,
      'backendUrl': backendUrl,
    };
  }

  factory AppSettings.fromData(AppSettingsTableData data) {
    return AppSettings(
      id: data.id,
      themeMode: data.themeMode,
      defaultVoiceId: data.defaultVoiceId,
      defaultSpeed: data.defaultSpeed,
      defaultFormat: data.defaultFormat,
      autoNormalize: data.autoNormalize,
      autoSplit: data.autoSplit,
      warningThreshold: data.warningThreshold,
      ttsProvider: data.ttsProvider,
      backendUrl: data.backendUrl,
    );
  }
}
