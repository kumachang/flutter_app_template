// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, implicit_dynamic_parameter, implicit_dynamic_type, implicit_dynamic_method, strict_raw_type

part of 'required_version_parameter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RequiredVersion _$RequiredVersionFromJson(Map json) => RequiredVersion(
      requiredBuildNumber: json['requiredBuildNumber'] as int,
      canCancel: json['canCancel'] as bool,
      enabledAt: DateTime.parse(json['enabledAt'] as String),
      isEnabled: json['isEnabled'] as bool,
    );

Map<String, dynamic> _$RequiredVersionToJson(RequiredVersion instance) =>
    <String, dynamic>{
      'requiredBuildNumber': instance.requiredBuildNumber,
      'enabledAt': instance.enabledAt.toIso8601String(),
      'isEnabled': instance.isEnabled,
      'canCancel': instance.canCancel,
    };
