// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'audio_asset.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AudioAsset _$AudioAssetFromJson(Map<String, dynamic> json) {
  return _AudioAsset.fromJson(json);
}

/// @nodoc
mixin _$AudioAsset {
  String get id => throw _privateConstructorUsedError;
  String? get scriptId => throw _privateConstructorUsedError;
  String? get projectId => throw _privateConstructorUsedError;
  String get fileName => throw _privateConstructorUsedError;
  String get filePath => throw _privateConstructorUsedError;
  int get fileSizeBytes => throw _privateConstructorUsedError;
  Duration get duration => throw _privateConstructorUsedError;
  String get format => throw _privateConstructorUsedError;
  int get sampleRate => throw _privateConstructorUsedError;
  int get channels => throw _privateConstructorUsedError;
  String? get voiceId => throw _privateConstructorUsedError;
  String? get generationJobId => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get deletedAt => throw _privateConstructorUsedError;
  bool get isDeleted => throw _privateConstructorUsedError;

  /// Serializes this AudioAsset to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AudioAsset
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AudioAssetCopyWith<AudioAsset> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AudioAssetCopyWith<$Res> {
  factory $AudioAssetCopyWith(
    AudioAsset value,
    $Res Function(AudioAsset) then,
  ) = _$AudioAssetCopyWithImpl<$Res, AudioAsset>;
  @useResult
  $Res call({
    String id,
    String? scriptId,
    String? projectId,
    String fileName,
    String filePath,
    int fileSizeBytes,
    Duration duration,
    String format,
    int sampleRate,
    int channels,
    String? voiceId,
    String? generationJobId,
    DateTime createdAt,
    DateTime? deletedAt,
    bool isDeleted,
  });
}

/// @nodoc
class _$AudioAssetCopyWithImpl<$Res, $Val extends AudioAsset>
    implements $AudioAssetCopyWith<$Res> {
  _$AudioAssetCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AudioAsset
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? scriptId = freezed,
    Object? projectId = freezed,
    Object? fileName = null,
    Object? filePath = null,
    Object? fileSizeBytes = null,
    Object? duration = null,
    Object? format = null,
    Object? sampleRate = null,
    Object? channels = null,
    Object? voiceId = freezed,
    Object? generationJobId = freezed,
    Object? createdAt = null,
    Object? deletedAt = freezed,
    Object? isDeleted = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            scriptId: freezed == scriptId
                ? _value.scriptId
                : scriptId // ignore: cast_nullable_to_non_nullable
                      as String?,
            projectId: freezed == projectId
                ? _value.projectId
                : projectId // ignore: cast_nullable_to_non_nullable
                      as String?,
            fileName: null == fileName
                ? _value.fileName
                : fileName // ignore: cast_nullable_to_non_nullable
                      as String,
            filePath: null == filePath
                ? _value.filePath
                : filePath // ignore: cast_nullable_to_non_nullable
                      as String,
            fileSizeBytes: null == fileSizeBytes
                ? _value.fileSizeBytes
                : fileSizeBytes // ignore: cast_nullable_to_non_nullable
                      as int,
            duration: null == duration
                ? _value.duration
                : duration // ignore: cast_nullable_to_non_nullable
                      as Duration,
            format: null == format
                ? _value.format
                : format // ignore: cast_nullable_to_non_nullable
                      as String,
            sampleRate: null == sampleRate
                ? _value.sampleRate
                : sampleRate // ignore: cast_nullable_to_non_nullable
                      as int,
            channels: null == channels
                ? _value.channels
                : channels // ignore: cast_nullable_to_non_nullable
                      as int,
            voiceId: freezed == voiceId
                ? _value.voiceId
                : voiceId // ignore: cast_nullable_to_non_nullable
                      as String?,
            generationJobId: freezed == generationJobId
                ? _value.generationJobId
                : generationJobId // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            deletedAt: freezed == deletedAt
                ? _value.deletedAt
                : deletedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            isDeleted: null == isDeleted
                ? _value.isDeleted
                : isDeleted // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AudioAssetImplCopyWith<$Res>
    implements $AudioAssetCopyWith<$Res> {
  factory _$$AudioAssetImplCopyWith(
    _$AudioAssetImpl value,
    $Res Function(_$AudioAssetImpl) then,
  ) = __$$AudioAssetImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String? scriptId,
    String? projectId,
    String fileName,
    String filePath,
    int fileSizeBytes,
    Duration duration,
    String format,
    int sampleRate,
    int channels,
    String? voiceId,
    String? generationJobId,
    DateTime createdAt,
    DateTime? deletedAt,
    bool isDeleted,
  });
}

/// @nodoc
class __$$AudioAssetImplCopyWithImpl<$Res>
    extends _$AudioAssetCopyWithImpl<$Res, _$AudioAssetImpl>
    implements _$$AudioAssetImplCopyWith<$Res> {
  __$$AudioAssetImplCopyWithImpl(
    _$AudioAssetImpl _value,
    $Res Function(_$AudioAssetImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AudioAsset
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? scriptId = freezed,
    Object? projectId = freezed,
    Object? fileName = null,
    Object? filePath = null,
    Object? fileSizeBytes = null,
    Object? duration = null,
    Object? format = null,
    Object? sampleRate = null,
    Object? channels = null,
    Object? voiceId = freezed,
    Object? generationJobId = freezed,
    Object? createdAt = null,
    Object? deletedAt = freezed,
    Object? isDeleted = null,
  }) {
    return _then(
      _$AudioAssetImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        scriptId: freezed == scriptId
            ? _value.scriptId
            : scriptId // ignore: cast_nullable_to_non_nullable
                  as String?,
        projectId: freezed == projectId
            ? _value.projectId
            : projectId // ignore: cast_nullable_to_non_nullable
                  as String?,
        fileName: null == fileName
            ? _value.fileName
            : fileName // ignore: cast_nullable_to_non_nullable
                  as String,
        filePath: null == filePath
            ? _value.filePath
            : filePath // ignore: cast_nullable_to_non_nullable
                  as String,
        fileSizeBytes: null == fileSizeBytes
            ? _value.fileSizeBytes
            : fileSizeBytes // ignore: cast_nullable_to_non_nullable
                  as int,
        duration: null == duration
            ? _value.duration
            : duration // ignore: cast_nullable_to_non_nullable
                  as Duration,
        format: null == format
            ? _value.format
            : format // ignore: cast_nullable_to_non_nullable
                  as String,
        sampleRate: null == sampleRate
            ? _value.sampleRate
            : sampleRate // ignore: cast_nullable_to_non_nullable
                  as int,
        channels: null == channels
            ? _value.channels
            : channels // ignore: cast_nullable_to_non_nullable
                  as int,
        voiceId: freezed == voiceId
            ? _value.voiceId
            : voiceId // ignore: cast_nullable_to_non_nullable
                  as String?,
        generationJobId: freezed == generationJobId
            ? _value.generationJobId
            : generationJobId // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        deletedAt: freezed == deletedAt
            ? _value.deletedAt
            : deletedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        isDeleted: null == isDeleted
            ? _value.isDeleted
            : isDeleted // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AudioAssetImpl implements _AudioAsset {
  const _$AudioAssetImpl({
    required this.id,
    this.scriptId,
    this.projectId,
    required this.fileName,
    required this.filePath,
    required this.fileSizeBytes,
    required this.duration,
    this.format = 'mp3',
    this.sampleRate = 24000,
    this.channels = 1,
    this.voiceId,
    this.generationJobId,
    required this.createdAt,
    this.deletedAt,
    this.isDeleted = false,
  });

  factory _$AudioAssetImpl.fromJson(Map<String, dynamic> json) =>
      _$$AudioAssetImplFromJson(json);

  @override
  final String id;
  @override
  final String? scriptId;
  @override
  final String? projectId;
  @override
  final String fileName;
  @override
  final String filePath;
  @override
  final int fileSizeBytes;
  @override
  final Duration duration;
  @override
  @JsonKey()
  final String format;
  @override
  @JsonKey()
  final int sampleRate;
  @override
  @JsonKey()
  final int channels;
  @override
  final String? voiceId;
  @override
  final String? generationJobId;
  @override
  final DateTime createdAt;
  @override
  final DateTime? deletedAt;
  @override
  @JsonKey()
  final bool isDeleted;

  @override
  String toString() {
    return 'AudioAsset(id: $id, scriptId: $scriptId, projectId: $projectId, fileName: $fileName, filePath: $filePath, fileSizeBytes: $fileSizeBytes, duration: $duration, format: $format, sampleRate: $sampleRate, channels: $channels, voiceId: $voiceId, generationJobId: $generationJobId, createdAt: $createdAt, deletedAt: $deletedAt, isDeleted: $isDeleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AudioAssetImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.scriptId, scriptId) ||
                other.scriptId == scriptId) &&
            (identical(other.projectId, projectId) ||
                other.projectId == projectId) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.filePath, filePath) ||
                other.filePath == filePath) &&
            (identical(other.fileSizeBytes, fileSizeBytes) ||
                other.fileSizeBytes == fileSizeBytes) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.format, format) || other.format == format) &&
            (identical(other.sampleRate, sampleRate) ||
                other.sampleRate == sampleRate) &&
            (identical(other.channels, channels) ||
                other.channels == channels) &&
            (identical(other.voiceId, voiceId) || other.voiceId == voiceId) &&
            (identical(other.generationJobId, generationJobId) ||
                other.generationJobId == generationJobId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.isDeleted, isDeleted) ||
                other.isDeleted == isDeleted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    scriptId,
    projectId,
    fileName,
    filePath,
    fileSizeBytes,
    duration,
    format,
    sampleRate,
    channels,
    voiceId,
    generationJobId,
    createdAt,
    deletedAt,
    isDeleted,
  );

  /// Create a copy of AudioAsset
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AudioAssetImplCopyWith<_$AudioAssetImpl> get copyWith =>
      __$$AudioAssetImplCopyWithImpl<_$AudioAssetImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AudioAssetImplToJson(this);
  }
}

abstract class _AudioAsset implements AudioAsset {
  const factory _AudioAsset({
    required final String id,
    final String? scriptId,
    final String? projectId,
    required final String fileName,
    required final String filePath,
    required final int fileSizeBytes,
    required final Duration duration,
    final String format,
    final int sampleRate,
    final int channels,
    final String? voiceId,
    final String? generationJobId,
    required final DateTime createdAt,
    final DateTime? deletedAt,
    final bool isDeleted,
  }) = _$AudioAssetImpl;

  factory _AudioAsset.fromJson(Map<String, dynamic> json) =
      _$AudioAssetImpl.fromJson;

  @override
  String get id;
  @override
  String? get scriptId;
  @override
  String? get projectId;
  @override
  String get fileName;
  @override
  String get filePath;
  @override
  int get fileSizeBytes;
  @override
  Duration get duration;
  @override
  String get format;
  @override
  int get sampleRate;
  @override
  int get channels;
  @override
  String? get voiceId;
  @override
  String? get generationJobId;
  @override
  DateTime get createdAt;
  @override
  DateTime? get deletedAt;
  @override
  bool get isDeleted;

  /// Create a copy of AudioAsset
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AudioAssetImplCopyWith<_$AudioAssetImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
