// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tts_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TtsRequest _$TtsRequestFromJson(Map<String, dynamic> json) {
  return _TtsRequest.fromJson(json);
}

/// @nodoc
mixin _$TtsRequest {
  String get id => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  String get voiceId => throw _privateConstructorUsedError;
  String get modelId => throw _privateConstructorUsedError;
  double get speed => throw _privateConstructorUsedError;
  double? get stability => throw _privateConstructorUsedError;
  double? get similarityBoost => throw _privateConstructorUsedError;
  double? get style => throw _privateConstructorUsedError;
  bool? get useSpeakerBoost => throw _privateConstructorUsedError;
  String get outputFormat => throw _privateConstructorUsedError;
  int get sampleRate => throw _privateConstructorUsedError;
  Map<String, dynamic>? get extraParams => throw _privateConstructorUsedError;

  /// Serializes this TtsRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TtsRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TtsRequestCopyWith<TtsRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TtsRequestCopyWith<$Res> {
  factory $TtsRequestCopyWith(
    TtsRequest value,
    $Res Function(TtsRequest) then,
  ) = _$TtsRequestCopyWithImpl<$Res, TtsRequest>;
  @useResult
  $Res call({
    String id,
    String text,
    String voiceId,
    String modelId,
    double speed,
    double? stability,
    double? similarityBoost,
    double? style,
    bool? useSpeakerBoost,
    String outputFormat,
    int sampleRate,
    Map<String, dynamic>? extraParams,
  });
}

/// @nodoc
class _$TtsRequestCopyWithImpl<$Res, $Val extends TtsRequest>
    implements $TtsRequestCopyWith<$Res> {
  _$TtsRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TtsRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? text = null,
    Object? voiceId = null,
    Object? modelId = null,
    Object? speed = null,
    Object? stability = freezed,
    Object? similarityBoost = freezed,
    Object? style = freezed,
    Object? useSpeakerBoost = freezed,
    Object? outputFormat = null,
    Object? sampleRate = null,
    Object? extraParams = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            text: null == text
                ? _value.text
                : text // ignore: cast_nullable_to_non_nullable
                      as String,
            voiceId: null == voiceId
                ? _value.voiceId
                : voiceId // ignore: cast_nullable_to_non_nullable
                      as String,
            modelId: null == modelId
                ? _value.modelId
                : modelId // ignore: cast_nullable_to_non_nullable
                      as String,
            speed: null == speed
                ? _value.speed
                : speed // ignore: cast_nullable_to_non_nullable
                      as double,
            stability: freezed == stability
                ? _value.stability
                : stability // ignore: cast_nullable_to_non_nullable
                      as double?,
            similarityBoost: freezed == similarityBoost
                ? _value.similarityBoost
                : similarityBoost // ignore: cast_nullable_to_non_nullable
                      as double?,
            style: freezed == style
                ? _value.style
                : style // ignore: cast_nullable_to_non_nullable
                      as double?,
            useSpeakerBoost: freezed == useSpeakerBoost
                ? _value.useSpeakerBoost
                : useSpeakerBoost // ignore: cast_nullable_to_non_nullable
                      as bool?,
            outputFormat: null == outputFormat
                ? _value.outputFormat
                : outputFormat // ignore: cast_nullable_to_non_nullable
                      as String,
            sampleRate: null == sampleRate
                ? _value.sampleRate
                : sampleRate // ignore: cast_nullable_to_non_nullable
                      as int,
            extraParams: freezed == extraParams
                ? _value.extraParams
                : extraParams // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TtsRequestImplCopyWith<$Res>
    implements $TtsRequestCopyWith<$Res> {
  factory _$$TtsRequestImplCopyWith(
    _$TtsRequestImpl value,
    $Res Function(_$TtsRequestImpl) then,
  ) = __$$TtsRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String text,
    String voiceId,
    String modelId,
    double speed,
    double? stability,
    double? similarityBoost,
    double? style,
    bool? useSpeakerBoost,
    String outputFormat,
    int sampleRate,
    Map<String, dynamic>? extraParams,
  });
}

/// @nodoc
class __$$TtsRequestImplCopyWithImpl<$Res>
    extends _$TtsRequestCopyWithImpl<$Res, _$TtsRequestImpl>
    implements _$$TtsRequestImplCopyWith<$Res> {
  __$$TtsRequestImplCopyWithImpl(
    _$TtsRequestImpl _value,
    $Res Function(_$TtsRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TtsRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? text = null,
    Object? voiceId = null,
    Object? modelId = null,
    Object? speed = null,
    Object? stability = freezed,
    Object? similarityBoost = freezed,
    Object? style = freezed,
    Object? useSpeakerBoost = freezed,
    Object? outputFormat = null,
    Object? sampleRate = null,
    Object? extraParams = freezed,
  }) {
    return _then(
      _$TtsRequestImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        text: null == text
            ? _value.text
            : text // ignore: cast_nullable_to_non_nullable
                  as String,
        voiceId: null == voiceId
            ? _value.voiceId
            : voiceId // ignore: cast_nullable_to_non_nullable
                  as String,
        modelId: null == modelId
            ? _value.modelId
            : modelId // ignore: cast_nullable_to_non_nullable
                  as String,
        speed: null == speed
            ? _value.speed
            : speed // ignore: cast_nullable_to_non_nullable
                  as double,
        stability: freezed == stability
            ? _value.stability
            : stability // ignore: cast_nullable_to_non_nullable
                  as double?,
        similarityBoost: freezed == similarityBoost
            ? _value.similarityBoost
            : similarityBoost // ignore: cast_nullable_to_non_nullable
                  as double?,
        style: freezed == style
            ? _value.style
            : style // ignore: cast_nullable_to_non_nullable
                  as double?,
        useSpeakerBoost: freezed == useSpeakerBoost
            ? _value.useSpeakerBoost
            : useSpeakerBoost // ignore: cast_nullable_to_non_nullable
                  as bool?,
        outputFormat: null == outputFormat
            ? _value.outputFormat
            : outputFormat // ignore: cast_nullable_to_non_nullable
                  as String,
        sampleRate: null == sampleRate
            ? _value.sampleRate
            : sampleRate // ignore: cast_nullable_to_non_nullable
                  as int,
        extraParams: freezed == extraParams
            ? _value._extraParams
            : extraParams // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TtsRequestImpl implements _TtsRequest {
  const _$TtsRequestImpl({
    required this.id,
    required this.text,
    required this.voiceId,
    this.modelId = '',
    this.speed = 1.0,
    this.stability,
    this.similarityBoost,
    this.style,
    this.useSpeakerBoost,
    this.outputFormat = 'mp3',
    this.sampleRate = 24000,
    final Map<String, dynamic>? extraParams,
  }) : _extraParams = extraParams;

  factory _$TtsRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$TtsRequestImplFromJson(json);

  @override
  final String id;
  @override
  final String text;
  @override
  final String voiceId;
  @override
  @JsonKey()
  final String modelId;
  @override
  @JsonKey()
  final double speed;
  @override
  final double? stability;
  @override
  final double? similarityBoost;
  @override
  final double? style;
  @override
  final bool? useSpeakerBoost;
  @override
  @JsonKey()
  final String outputFormat;
  @override
  @JsonKey()
  final int sampleRate;
  final Map<String, dynamic>? _extraParams;
  @override
  Map<String, dynamic>? get extraParams {
    final value = _extraParams;
    if (value == null) return null;
    if (_extraParams is EqualUnmodifiableMapView) return _extraParams;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'TtsRequest(id: $id, text: $text, voiceId: $voiceId, modelId: $modelId, speed: $speed, stability: $stability, similarityBoost: $similarityBoost, style: $style, useSpeakerBoost: $useSpeakerBoost, outputFormat: $outputFormat, sampleRate: $sampleRate, extraParams: $extraParams)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TtsRequestImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.voiceId, voiceId) || other.voiceId == voiceId) &&
            (identical(other.modelId, modelId) || other.modelId == modelId) &&
            (identical(other.speed, speed) || other.speed == speed) &&
            (identical(other.stability, stability) ||
                other.stability == stability) &&
            (identical(other.similarityBoost, similarityBoost) ||
                other.similarityBoost == similarityBoost) &&
            (identical(other.style, style) || other.style == style) &&
            (identical(other.useSpeakerBoost, useSpeakerBoost) ||
                other.useSpeakerBoost == useSpeakerBoost) &&
            (identical(other.outputFormat, outputFormat) ||
                other.outputFormat == outputFormat) &&
            (identical(other.sampleRate, sampleRate) ||
                other.sampleRate == sampleRate) &&
            const DeepCollectionEquality().equals(
              other._extraParams,
              _extraParams,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    text,
    voiceId,
    modelId,
    speed,
    stability,
    similarityBoost,
    style,
    useSpeakerBoost,
    outputFormat,
    sampleRate,
    const DeepCollectionEquality().hash(_extraParams),
  );

  /// Create a copy of TtsRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TtsRequestImplCopyWith<_$TtsRequestImpl> get copyWith =>
      __$$TtsRequestImplCopyWithImpl<_$TtsRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TtsRequestImplToJson(this);
  }
}

abstract class _TtsRequest implements TtsRequest {
  const factory _TtsRequest({
    required final String id,
    required final String text,
    required final String voiceId,
    final String modelId,
    final double speed,
    final double? stability,
    final double? similarityBoost,
    final double? style,
    final bool? useSpeakerBoost,
    final String outputFormat,
    final int sampleRate,
    final Map<String, dynamic>? extraParams,
  }) = _$TtsRequestImpl;

  factory _TtsRequest.fromJson(Map<String, dynamic> json) =
      _$TtsRequestImpl.fromJson;

  @override
  String get id;
  @override
  String get text;
  @override
  String get voiceId;
  @override
  String get modelId;
  @override
  double get speed;
  @override
  double? get stability;
  @override
  double? get similarityBoost;
  @override
  double? get style;
  @override
  bool? get useSpeakerBoost;
  @override
  String get outputFormat;
  @override
  int get sampleRate;
  @override
  Map<String, dynamic>? get extraParams;

  /// Create a copy of TtsRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TtsRequestImplCopyWith<_$TtsRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
