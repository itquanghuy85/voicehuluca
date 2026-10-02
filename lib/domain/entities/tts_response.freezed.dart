// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tts_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TtsResponse _$TtsResponseFromJson(Map<String, dynamic> json) {
  return _TtsResponse.fromJson(json);
}

/// @nodoc
mixin _$TtsResponse {
  String get id => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get audioUrl => throw _privateConstructorUsedError;
  Duration? get duration => throw _privateConstructorUsedError;
  int? get characterCount => throw _privateConstructorUsedError;
  String? get providerRequestId => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this TtsResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TtsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TtsResponseCopyWith<TtsResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TtsResponseCopyWith<$Res> {
  factory $TtsResponseCopyWith(
    TtsResponse value,
    $Res Function(TtsResponse) then,
  ) = _$TtsResponseCopyWithImpl<$Res, TtsResponse>;
  @useResult
  $Res call({
    String id,
    String status,
    String? audioUrl,
    Duration? duration,
    int? characterCount,
    String? providerRequestId,
    String? errorMessage,
    Map<String, dynamic>? metadata,
    DateTime createdAt,
  });
}

/// @nodoc
class _$TtsResponseCopyWithImpl<$Res, $Val extends TtsResponse>
    implements $TtsResponseCopyWith<$Res> {
  _$TtsResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TtsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? audioUrl = freezed,
    Object? duration = freezed,
    Object? characterCount = freezed,
    Object? providerRequestId = freezed,
    Object? errorMessage = freezed,
    Object? metadata = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            audioUrl: freezed == audioUrl
                ? _value.audioUrl
                : audioUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            duration: freezed == duration
                ? _value.duration
                : duration // ignore: cast_nullable_to_non_nullable
                      as Duration?,
            characterCount: freezed == characterCount
                ? _value.characterCount
                : characterCount // ignore: cast_nullable_to_non_nullable
                      as int?,
            providerRequestId: freezed == providerRequestId
                ? _value.providerRequestId
                : providerRequestId // ignore: cast_nullable_to_non_nullable
                      as String?,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TtsResponseImplCopyWith<$Res>
    implements $TtsResponseCopyWith<$Res> {
  factory _$$TtsResponseImplCopyWith(
    _$TtsResponseImpl value,
    $Res Function(_$TtsResponseImpl) then,
  ) = __$$TtsResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String status,
    String? audioUrl,
    Duration? duration,
    int? characterCount,
    String? providerRequestId,
    String? errorMessage,
    Map<String, dynamic>? metadata,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$TtsResponseImplCopyWithImpl<$Res>
    extends _$TtsResponseCopyWithImpl<$Res, _$TtsResponseImpl>
    implements _$$TtsResponseImplCopyWith<$Res> {
  __$$TtsResponseImplCopyWithImpl(
    _$TtsResponseImpl _value,
    $Res Function(_$TtsResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TtsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? audioUrl = freezed,
    Object? duration = freezed,
    Object? characterCount = freezed,
    Object? providerRequestId = freezed,
    Object? errorMessage = freezed,
    Object? metadata = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$TtsResponseImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        audioUrl: freezed == audioUrl
            ? _value.audioUrl
            : audioUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        duration: freezed == duration
            ? _value.duration
            : duration // ignore: cast_nullable_to_non_nullable
                  as Duration?,
        characterCount: freezed == characterCount
            ? _value.characterCount
            : characterCount // ignore: cast_nullable_to_non_nullable
                  as int?,
        providerRequestId: freezed == providerRequestId
            ? _value.providerRequestId
            : providerRequestId // ignore: cast_nullable_to_non_nullable
                  as String?,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
        metadata: freezed == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TtsResponseImpl implements _TtsResponse {
  const _$TtsResponseImpl({
    required this.id,
    required this.status,
    this.audioUrl,
    this.duration,
    this.characterCount,
    this.providerRequestId,
    this.errorMessage,
    final Map<String, dynamic>? metadata,
    required this.createdAt,
  }) : _metadata = metadata;

  factory _$TtsResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$TtsResponseImplFromJson(json);

  @override
  final String id;
  @override
  final String status;
  @override
  final String? audioUrl;
  @override
  final Duration? duration;
  @override
  final int? characterCount;
  @override
  final String? providerRequestId;
  @override
  final String? errorMessage;
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
  final DateTime createdAt;

  @override
  String toString() {
    return 'TtsResponse(id: $id, status: $status, audioUrl: $audioUrl, duration: $duration, characterCount: $characterCount, providerRequestId: $providerRequestId, errorMessage: $errorMessage, metadata: $metadata, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TtsResponseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.audioUrl, audioUrl) ||
                other.audioUrl == audioUrl) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.characterCount, characterCount) ||
                other.characterCount == characterCount) &&
            (identical(other.providerRequestId, providerRequestId) ||
                other.providerRequestId == providerRequestId) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    status,
    audioUrl,
    duration,
    characterCount,
    providerRequestId,
    errorMessage,
    const DeepCollectionEquality().hash(_metadata),
    createdAt,
  );

  /// Create a copy of TtsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TtsResponseImplCopyWith<_$TtsResponseImpl> get copyWith =>
      __$$TtsResponseImplCopyWithImpl<_$TtsResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TtsResponseImplToJson(this);
  }
}

abstract class _TtsResponse implements TtsResponse {
  const factory _TtsResponse({
    required final String id,
    required final String status,
    final String? audioUrl,
    final Duration? duration,
    final int? characterCount,
    final String? providerRequestId,
    final String? errorMessage,
    final Map<String, dynamic>? metadata,
    required final DateTime createdAt,
  }) = _$TtsResponseImpl;

  factory _TtsResponse.fromJson(Map<String, dynamic> json) =
      _$TtsResponseImpl.fromJson;

  @override
  String get id;
  @override
  String get status;
  @override
  String? get audioUrl;
  @override
  Duration? get duration;
  @override
  int? get characterCount;
  @override
  String? get providerRequestId;
  @override
  String? get errorMessage;
  @override
  Map<String, dynamic>? get metadata;
  @override
  DateTime get createdAt;

  /// Create a copy of TtsResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TtsResponseImplCopyWith<_$TtsResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
