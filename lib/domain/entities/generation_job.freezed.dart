// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'generation_job.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GenerationJob _$GenerationJobFromJson(Map<String, dynamic> json) {
  return _GenerationJob.fromJson(json);
}

/// @nodoc
mixin _$GenerationJob {
  String get id => throw _privateConstructorUsedError;
  String? get scriptId => throw _privateConstructorUsedError;
  String? get projectId => throw _privateConstructorUsedError;
  String get voiceId => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  GenerationStatus get status => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  String? get audioAssetId => throw _privateConstructorUsedError;
  String? get ttsRequestId => throw _privateConstructorUsedError;
  double get progress => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get startedAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;
  DateTime? get cancelledAt => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this GenerationJob to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GenerationJob
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GenerationJobCopyWith<GenerationJob> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GenerationJobCopyWith<$Res> {
  factory $GenerationJobCopyWith(
    GenerationJob value,
    $Res Function(GenerationJob) then,
  ) = _$GenerationJobCopyWithImpl<$Res, GenerationJob>;
  @useResult
  $Res call({
    String id,
    String? scriptId,
    String? projectId,
    String voiceId,
    String text,
    GenerationStatus status,
    String? errorMessage,
    String? audioAssetId,
    String? ttsRequestId,
    double progress,
    DateTime createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class _$GenerationJobCopyWithImpl<$Res, $Val extends GenerationJob>
    implements $GenerationJobCopyWith<$Res> {
  _$GenerationJobCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GenerationJob
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? scriptId = freezed,
    Object? projectId = freezed,
    Object? voiceId = null,
    Object? text = null,
    Object? status = null,
    Object? errorMessage = freezed,
    Object? audioAssetId = freezed,
    Object? ttsRequestId = freezed,
    Object? progress = null,
    Object? createdAt = null,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
    Object? cancelledAt = freezed,
    Object? metadata = freezed,
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
            voiceId: null == voiceId
                ? _value.voiceId
                : voiceId // ignore: cast_nullable_to_non_nullable
                      as String,
            text: null == text
                ? _value.text
                : text // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as GenerationStatus,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
            audioAssetId: freezed == audioAssetId
                ? _value.audioAssetId
                : audioAssetId // ignore: cast_nullable_to_non_nullable
                      as String?,
            ttsRequestId: freezed == ttsRequestId
                ? _value.ttsRequestId
                : ttsRequestId // ignore: cast_nullable_to_non_nullable
                      as String?,
            progress: null == progress
                ? _value.progress
                : progress // ignore: cast_nullable_to_non_nullable
                      as double,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            startedAt: freezed == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            completedAt: freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            cancelledAt: freezed == cancelledAt
                ? _value.cancelledAt
                : cancelledAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GenerationJobImplCopyWith<$Res>
    implements $GenerationJobCopyWith<$Res> {
  factory _$$GenerationJobImplCopyWith(
    _$GenerationJobImpl value,
    $Res Function(_$GenerationJobImpl) then,
  ) = __$$GenerationJobImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String? scriptId,
    String? projectId,
    String voiceId,
    String text,
    GenerationStatus status,
    String? errorMessage,
    String? audioAssetId,
    String? ttsRequestId,
    double progress,
    DateTime createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class __$$GenerationJobImplCopyWithImpl<$Res>
    extends _$GenerationJobCopyWithImpl<$Res, _$GenerationJobImpl>
    implements _$$GenerationJobImplCopyWith<$Res> {
  __$$GenerationJobImplCopyWithImpl(
    _$GenerationJobImpl _value,
    $Res Function(_$GenerationJobImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GenerationJob
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? scriptId = freezed,
    Object? projectId = freezed,
    Object? voiceId = null,
    Object? text = null,
    Object? status = null,
    Object? errorMessage = freezed,
    Object? audioAssetId = freezed,
    Object? ttsRequestId = freezed,
    Object? progress = null,
    Object? createdAt = null,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
    Object? cancelledAt = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _$GenerationJobImpl(
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
        voiceId: null == voiceId
            ? _value.voiceId
            : voiceId // ignore: cast_nullable_to_non_nullable
                  as String,
        text: null == text
            ? _value.text
            : text // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as GenerationStatus,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
        audioAssetId: freezed == audioAssetId
            ? _value.audioAssetId
            : audioAssetId // ignore: cast_nullable_to_non_nullable
                  as String?,
        ttsRequestId: freezed == ttsRequestId
            ? _value.ttsRequestId
            : ttsRequestId // ignore: cast_nullable_to_non_nullable
                  as String?,
        progress: null == progress
            ? _value.progress
            : progress // ignore: cast_nullable_to_non_nullable
                  as double,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        startedAt: freezed == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        completedAt: freezed == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        cancelledAt: freezed == cancelledAt
            ? _value.cancelledAt
            : cancelledAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        metadata: freezed == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GenerationJobImpl implements _GenerationJob {
  const _$GenerationJobImpl({
    required this.id,
    this.scriptId,
    this.projectId,
    required this.voiceId,
    required this.text,
    this.status = GenerationStatus.idle,
    this.errorMessage,
    this.audioAssetId,
    this.ttsRequestId,
    this.progress = 0.0,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    final Map<String, dynamic>? metadata,
  }) : _metadata = metadata;

  factory _$GenerationJobImpl.fromJson(Map<String, dynamic> json) =>
      _$$GenerationJobImplFromJson(json);

  @override
  final String id;
  @override
  final String? scriptId;
  @override
  final String? projectId;
  @override
  final String voiceId;
  @override
  final String text;
  @override
  @JsonKey()
  final GenerationStatus status;
  @override
  final String? errorMessage;
  @override
  final String? audioAssetId;
  @override
  final String? ttsRequestId;
  @override
  @JsonKey()
  final double progress;
  @override
  final DateTime createdAt;
  @override
  final DateTime? startedAt;
  @override
  final DateTime? completedAt;
  @override
  final DateTime? cancelledAt;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'GenerationJob(id: $id, scriptId: $scriptId, projectId: $projectId, voiceId: $voiceId, text: $text, status: $status, errorMessage: $errorMessage, audioAssetId: $audioAssetId, ttsRequestId: $ttsRequestId, progress: $progress, createdAt: $createdAt, startedAt: $startedAt, completedAt: $completedAt, cancelledAt: $cancelledAt, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GenerationJobImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.scriptId, scriptId) ||
                other.scriptId == scriptId) &&
            (identical(other.projectId, projectId) ||
                other.projectId == projectId) &&
            (identical(other.voiceId, voiceId) || other.voiceId == voiceId) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.audioAssetId, audioAssetId) ||
                other.audioAssetId == audioAssetId) &&
            (identical(other.ttsRequestId, ttsRequestId) ||
                other.ttsRequestId == ttsRequestId) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.cancelledAt, cancelledAt) ||
                other.cancelledAt == cancelledAt) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    scriptId,
    projectId,
    voiceId,
    text,
    status,
    errorMessage,
    audioAssetId,
    ttsRequestId,
    progress,
    createdAt,
    startedAt,
    completedAt,
    cancelledAt,
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of GenerationJob
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GenerationJobImplCopyWith<_$GenerationJobImpl> get copyWith =>
      __$$GenerationJobImplCopyWithImpl<_$GenerationJobImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GenerationJobImplToJson(this);
  }
}

abstract class _GenerationJob implements GenerationJob {
  const factory _GenerationJob({
    required final String id,
    final String? scriptId,
    final String? projectId,
    required final String voiceId,
    required final String text,
    final GenerationStatus status,
    final String? errorMessage,
    final String? audioAssetId,
    final String? ttsRequestId,
    final double progress,
    required final DateTime createdAt,
    final DateTime? startedAt,
    final DateTime? completedAt,
    final DateTime? cancelledAt,
    final Map<String, dynamic>? metadata,
  }) = _$GenerationJobImpl;

  factory _GenerationJob.fromJson(Map<String, dynamic> json) =
      _$GenerationJobImpl.fromJson;

  @override
  String get id;
  @override
  String? get scriptId;
  @override
  String? get projectId;
  @override
  String get voiceId;
  @override
  String get text;
  @override
  GenerationStatus get status;
  @override
  String? get errorMessage;
  @override
  String? get audioAssetId;
  @override
  String? get ttsRequestId;
  @override
  double get progress;
  @override
  DateTime get createdAt;
  @override
  DateTime? get startedAt;
  @override
  DateTime? get completedAt;
  @override
  DateTime? get cancelledAt;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of GenerationJob
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GenerationJobImplCopyWith<_$GenerationJobImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
