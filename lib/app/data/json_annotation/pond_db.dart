import 'package:json_annotation/json_annotation.dart';

part 'pond_db.g.dart';

@JsonSerializable()
class PondDB {
  final int id;
  final String name;
  final double volume;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  // Trường này không có trong JSON trả về từ GET, nhưng cần thiết khi POST/PUT
  @JsonKey(includeIfNull: false)
  final int? system;

  PondDB({
    required this.id,
    required this.name,
    required this.volume,
    required this.createdAt,
    this.system,
  });

  factory PondDB.fromJson(Map<String, dynamic> json) => _$PondDBFromJson(json);

  Map<String, dynamic> toJson() => _$PondDBToJson(this);
}