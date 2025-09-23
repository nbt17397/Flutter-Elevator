// Import `json_annotation` để hỗ trợ serialization
import 'package:json_annotation/json_annotation.dart';

// Import các file cần thiết
part 'unit_db.g.dart';

@JsonSerializable()
class UnitDB {
  final int id;
  final String type;
  final String name;
  final String? description;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  final int location;

  UnitDB({
    required this.id,
    required this.type,
    required this.name,
    this.description,
    required this.createdAt,
    required this.location,
  });

  // Factory constructor để tạo đối tượng UnitDB từ JSON
  factory UnitDB.fromJson(Map<String, dynamic> json) => _$UnitDBFromJson(json);

  // Phương thức để chuyển đổi đối tượng UnitDB sang JSON
  Map<String, dynamic> toJson() => _$UnitDBToJson(this);
}