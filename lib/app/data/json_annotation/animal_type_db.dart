import 'package:json_annotation/json_annotation.dart';

part 'animal_type_db.g.dart';

@JsonSerializable()
class AnimalTypeDB {
  final int id;
  final String name;
  final String? description;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  
  final int location;

  AnimalTypeDB({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    required this.location,
  });

  factory AnimalTypeDB.fromJson(Map<String, dynamic> json) => _$AnimalTypeDBFromJson(json);

  Map<String, dynamic> toJson() => _$AnimalTypeDBToJson(this);
}