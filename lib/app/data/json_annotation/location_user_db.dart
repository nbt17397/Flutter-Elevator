import 'package:json_annotation/json_annotation.dart';

part 'location_user_db.g.dart';

@JsonSerializable()
class LocationUserDB {
  final int id;
  final int location;
  final int user;

  @JsonKey(name: 'user_name')
  final String? userName;

  final String role;

  @JsonKey(name: 'joined_at')
  final DateTime joinedAt;

  LocationUserDB({
    required this.id,
    required this.location,
    required this.user,
    this.userName,
    required this.role,
    required this.joinedAt,
  });

  factory LocationUserDB.fromJson(Map<String, dynamic> json) => _$LocationUserDBFromJson(json);

  Map<String, dynamic> toJson() => _$LocationUserDBToJson(this);
}