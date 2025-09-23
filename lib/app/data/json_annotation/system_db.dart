import 'package:json_annotation/json_annotation.dart';

part 'system_db.g.dart';

@JsonSerializable()
class SystemDB {
  final int id;
  final String name;
  final String? description;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  final int location;

  SystemDB({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    required this.location,
  });

  factory SystemDB.fromJson(Map<String, dynamic> json) => _$SystemDBFromJson(json);

  Map<String, dynamic> toJson() => _$SystemDBToJson(this);
}