// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AppSettings _$AppSettingsFromJson(Map<String, dynamic> json) {
  return _AppSettings.fromJson(json);
}

/// @nodoc
mixin _$AppSettings {
  String get id => throw _privateConstructorUsedError;
  String get apiKey => throw _privateConstructorUsedError;
  String get defaultVoiceId => throw _privateConstructorUsedError;
  String get defaultModelId => throw _privateConstructorUsedError;
  double get defaultSpeed => throw _privateConstructorUsedError;
  String get defaultOutputFormat => throw _privateConstructorUsedError;
  int get defaultSampleRate => throw _privateConstructorUsedError;
  String get language => throw _privateConstructorUsedError;
  String get theme => throw _privateConstructorUsedError;
  bool get autoSave => throw _privateConstructorUsedError;
  bool get enableNotifications => throw _privateConstructorUsedError;
  int get maxConcurrentGenerations => throw _privateConstructorUsedError;
  Duration get requestTimeout => throw _privateConstructorUsedError;
  String? get webhookUrl => throw _privateConstructorUsedError;
  Map<String, dynamic>? get customHeaders => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this AppSettings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AppSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppSettingsCopyWith<AppSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppSettingsCopyWith<$Res> {
  factory $AppSettingsCopyWith(
    AppSettings value,
    $Res Function(AppSettings) then,
  ) = _$AppSettingsCopyWithImpl<$Res, AppSettings>;
  @useResult
  $Res call({
    String id,
    String apiKey,
    String defaultVoiceId,
    String defaultModelId,
    double defaultSpeed,
    String defaultOutputFormat,
    int defaultSampleRate,
    String language,
    String theme,
    bool autoSave,
    bool enableNotifications,
    int maxConcurrentGenerations,
    Duration requestTimeout,
    String? webhookUrl,
    Map<String, dynamic>? customHeaders,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$AppSettingsCopyWithImpl<$Res, $Val extends AppSettings>
    implements $AppSettingsCopyWith<$Res> {
  _$AppSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? apiKey = null,
    Object? defaultVoiceId = null,
    Object? defaultModelId = null,
    Object? defaultSpeed = null,
    Object? defaultOutputFormat = null,
    Object? defaultSampleRate = null,
    Object? language = null,
    Object? theme = null,
    Object? autoSave = null,
    Object? enableNotifications = null,
    Object? maxConcurrentGenerations = null,
    Object? requestTimeout = null,
    Object? webhookUrl = freezed,
    Object? customHeaders = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            apiKey: null == apiKey
                ? _value.apiKey
                : apiKey // ignore: cast_nullable_to_non_nullable
                      as String,
            defaultVoiceId: null == defaultVoiceId
                ? _value.defaultVoiceId
                : defaultVoiceId // ignore: cast_nullable_to_non_nullable
                      as String,
            defaultModelId: null == defaultModelId
                ? _value.defaultModelId
                : defaultModelId // ignore: cast_nullable_to_non_nullable
                      as String,
            defaultSpeed: null == defaultSpeed
                ? _value.defaultSpeed
                : defaultSpeed // ignore: cast_nullable_to_non_nullable
                      as double,
            defaultOutputFormat: null == defaultOutputFormat
                ? _value.defaultOutputFormat
                : defaultOutputFormat // ignore: cast_nullable_to_non_nullable
                      as String,
            defaultSampleRate: null == defaultSampleRate
                ? _value.defaultSampleRate
                : defaultSampleRate // ignore: cast_nullable_to_non_nullable
                      as int,
            language: null == language
                ? _value.language
                : language // ignore: cast_nullable_to_non_nullable
                      as String,
            theme: null == theme
                ? _value.theme
                : theme // ignore: cast_nullable_to_non_nullable
                      as String,
            autoSave: null == autoSave
                ? _value.autoSave
                : autoSave // ignore: cast_nullable_to_non_nullable
                      as bool,
            enableNotifications: null == enableNotifications
                ? _value.enableNotifications
                : enableNotifications // ignore: cast_nullable_to_non_nullable
                      as bool,
            maxConcurrentGenerations: null == maxConcurrentGenerations
                ? _value.maxConcurrentGenerations
                : maxConcurrentGenerations // ignore: cast_nullable_to_non_nullable
                      as int,
            requestTimeout: null == requestTimeout
                ? _value.requestTimeout
                : requestTimeout // ignore: cast_nullable_to_non_nullable
                      as Duration,
            webhookUrl: freezed == webhookUrl
                ? _value.webhookUrl
                : webhookUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            customHeaders: freezed == customHeaders
                ? _value.customHeaders
                : customHeaders // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AppSettingsImplCopyWith<$Res>
    implements $AppSettingsCopyWith<$Res> {
  factory _$$AppSettingsImplCopyWith(
    _$AppSettingsImpl value,
    $Res Function(_$AppSettingsImpl) then,
  ) = __$$AppSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String apiKey,
    String defaultVoiceId,
    String defaultModelId,
    double defaultSpeed,
    String defaultOutputFormat,
    int defaultSampleRate,
    String language,
    String theme,
    bool autoSave,
    bool enableNotifications,
    int maxConcurrentGenerations,
    Duration requestTimeout,
    String? webhookUrl,
    Map<String, dynamic>? customHeaders,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$AppSettingsImplCopyWithImpl<$Res>
    extends _$AppSettingsCopyWithImpl<$Res, _$AppSettingsImpl>
    implements _$$AppSettingsImplCopyWith<$Res> {
  __$$AppSettingsImplCopyWithImpl(
    _$AppSettingsImpl _value,
    $Res Function(_$AppSettingsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? apiKey = null,
    Object? defaultVoiceId = null,
    Object? defaultModelId = null,
    Object? defaultSpeed = null,
    Object? defaultOutputFormat = null,
    Object? defaultSampleRate = null,
    Object? language = null,
    Object? theme = null,
    Object? autoSave = null,
    Object? enableNotifications = null,
    Object? maxConcurrentGenerations = null,
    Object? requestTimeout = null,
    Object? webhookUrl = freezed,
    Object? customHeaders = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$AppSettingsImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        apiKey: null == apiKey
            ? _value.apiKey
            : apiKey // ignore: cast_nullable_to_non_nullable
                  as String,
        defaultVoiceId: null == defaultVoiceId
            ? _value.defaultVoiceId
            : defaultVoiceId // ignore: cast_nullable_to_non_nullable
                  as String,
        defaultModelId: null == defaultModelId
            ? _value.defaultModelId
            : defaultModelId // ignore: cast_nullable_to_non_nullable
                  as String,
        defaultSpeed: null == defaultSpeed
            ? _value.defaultSpeed
            : defaultSpeed // ignore: cast_nullable_to_non_nullable
                  as double,
        defaultOutputFormat: null == defaultOutputFormat
            ? _value.defaultOutputFormat
            : defaultOutputFormat // ignore: cast_nullable_to_non_nullable
                  as String,
        defaultSampleRate: null == defaultSampleRate
            ? _value.defaultSampleRate
            : defaultSampleRate // ignore: cast_nullable_to_non_nullable
                  as int,
        language: null == language
            ? _value.language
            : language // ignore: cast_nullable_to_non_nullable
                  as String,
        theme: null == theme
            ? _value.theme
            : theme // ignore: cast_nullable_to_non_nullable
                  as String,
        autoSave: null == autoSave
            ? _value.autoSave
            : autoSave // ignore: cast_nullable_to_non_nullable
                  as bool,
        enableNotifications: null == enableNotifications
            ? _value.enableNotifications
            : enableNotifications // ignore: cast_nullable_to_non_nullable
                  as bool,
        maxConcurrentGenerations: null == maxConcurrentGenerations
            ? _value.maxConcurrentGenerations
            : maxConcurrentGenerations // ignore: cast_nullable_to_non_nullable
                  as int,
        requestTimeout: null == requestTimeout
            ? _value.requestTimeout
            : requestTimeout // ignore: cast_nullable_to_non_nullable
                  as Duration,
        webhookUrl: freezed == webhookUrl
            ? _value.webhookUrl
            : webhookUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        customHeaders: freezed == customHeaders
            ? _value._customHeaders
            : customHeaders // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AppSettingsImpl implements _AppSettings {
  const _$AppSettingsImpl({
    this.id = 'default',
    this.apiKey = '',
    this.defaultVoiceId = '',
    this.defaultModelId = '',
    this.defaultSpeed = 1.0,
    this.defaultOutputFormat = 'mp3',
    this.defaultSampleRate = 24000,
    this.language = 'vi',
    this.theme = 'system',
    this.autoSave = true,
    this.enableNotifications = true,
    this.maxConcurrentGenerations = 3,
    this.requestTimeout = const Duration(seconds: 60),
    this.webhookUrl,
    final Map<String, dynamic>? customHeaders,
    required this.createdAt,
    required this.updatedAt,
  }) : _customHeaders = customHeaders;

  factory _$AppSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppSettingsImplFromJson(json);

  @override
  @JsonKey()
  final String id;
  @override
  @JsonKey()
  final String apiKey;
  @override
  @JsonKey()
  final String defaultVoiceId;
  @override
  @JsonKey()
  final String defaultModelId;
  @override
  @JsonKey()
  final double defaultSpeed;
  @override
  @JsonKey()
  final String defaultOutputFormat;
  @override
  @JsonKey()
  final int defaultSampleRate;
  @override
  @JsonKey()
  final String language;
  @override
  @JsonKey()
  final String theme;
  @override
  @JsonKey()
  final bool autoSave;
  @override
  @JsonKey()
  final bool enableNotifications;
  @override
  @JsonKey()
  final int maxConcurrentGenerations;
  @override
  @JsonKey()
  final Duration requestTimeout;
  @override
  final String? webhookUrl;
  final Map<String, dynamic>? _customHeaders;
  @override
  Map<String, dynamic>? get customHeaders {
    final value = _customHeaders;
    if (value == null) return null;
    if (_customHeaders is EqualUnmodifiableMapView) return _customHeaders;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'AppSettings(id: $id, apiKey: $apiKey, defaultVoiceId: $defaultVoiceId, defaultModelId: $defaultModelId, defaultSpeed: $defaultSpeed, defaultOutputFormat: $defaultOutputFormat, defaultSampleRate: $defaultSampleRate, language: $language, theme: $theme, autoSave: $autoSave, enableNotifications: $enableNotifications, maxConcurrentGenerations: $maxConcurrentGenerations, requestTimeout: $requestTimeout, webhookUrl: $webhookUrl, customHeaders: $customHeaders, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppSettingsImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.apiKey, apiKey) || other.apiKey == apiKey) &&
            (identical(other.defaultVoiceId, defaultVoiceId) ||
                other.defaultVoiceId == defaultVoiceId) &&
            (identical(other.defaultModelId, defaultModelId) ||
                other.defaultModelId == defaultModelId) &&
            (identical(other.defaultSpeed, defaultSpeed) ||
                other.defaultSpeed == defaultSpeed) &&
            (identical(other.defaultOutputFormat, defaultOutputFormat) ||
                other.defaultOutputFormat == defaultOutputFormat) &&
            (identical(other.defaultSampleRate, defaultSampleRate) ||
                other.defaultSampleRate == defaultSampleRate) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.theme, theme) || other.theme == theme) &&
            (identical(other.autoSave, autoSave) ||
                other.autoSave == autoSave) &&
            (identical(other.enableNotifications, enableNotifications) ||
                other.enableNotifications == enableNotifications) &&
            (identical(
                  other.maxConcurrentGenerations,
                  maxConcurrentGenerations,
                ) ||
                other.maxConcurrentGenerations == maxConcurrentGenerations) &&
            (identical(other.requestTimeout, requestTimeout) ||
                other.requestTimeout == requestTimeout) &&
            (identical(other.webhookUrl, webhookUrl) ||
                other.webhookUrl == webhookUrl) &&
            const DeepCollectionEquality().equals(
              other._customHeaders,
              _customHeaders,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    apiKey,
    defaultVoiceId,
    defaultModelId,
    defaultSpeed,
    defaultOutputFormat,
    defaultSampleRate,
    language,
    theme,
    autoSave,
    enableNotifications,
    maxConcurrentGenerations,
    requestTimeout,
    webhookUrl,
    const DeepCollectionEquality().hash(_customHeaders),
    createdAt,
    updatedAt,
  );

  /// Create a copy of AppSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppSettingsImplCopyWith<_$AppSettingsImpl> get copyWith =>
      __$$AppSettingsImplCopyWithImpl<_$AppSettingsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppSettingsImplToJson(this);
  }
}

abstract class _AppSettings implements AppSettings {
  const factory _AppSettings({
    final String id,
    final String apiKey,
    final String defaultVoiceId,
    final String defaultModelId,
    final double defaultSpeed,
    final String defaultOutputFormat,
    final int defaultSampleRate,
    final String language,
    final String theme,
    final bool autoSave,
    final bool enableNotifications,
    final int maxConcurrentGenerations,
    final Duration requestTimeout,
    final String? webhookUrl,
    final Map<String, dynamic>? customHeaders,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$AppSettingsImpl;

  factory _AppSettings.fromJson(Map<String, dynamic> json) =
      _$AppSettingsImpl.fromJson;

  @override
  String get id;
  @override
  String get apiKey;
  @override
  String get defaultVoiceId;
  @override
  String get defaultModelId;
  @override
  double get defaultSpeed;
  @override
  String get defaultOutputFormat;
  @override
  int get defaultSampleRate;
  @override
  String get language;
  @override
  String get theme;
  @override
  bool get autoSave;
  @override
  bool get enableNotifications;
  @override
  int get maxConcurrentGenerations;
  @override
  Duration get requestTimeout;
  @override
  String? get webhookUrl;
  @override
  Map<String, dynamic>? get customHeaders;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of AppSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppSettingsImplCopyWith<_$AppSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
