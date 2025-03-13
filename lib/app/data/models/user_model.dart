// note you have to hardcode this part
// for example => (part 'classname.g.dart');
// class name must be in lower case
import 'package:hive/hive.dart';

// this line must be written by you
// for example => ( part 'filename.g.dart'; )
// FILENAME not class name and also all in lower case
part 'user_model.g.dart';

@HiveType(typeId: 1) // id must be unique
class UserModel {
  @HiveField(0)
  final String username;
  @HiveField(1)
  final bool isSuperuser;
  @HiveField(2)
  final String email;
  @HiveField(3)
  final String name;
  @HiveField(4)
  final int userId;
  @HiveField(5)
  final String accessToken;

  // you must provide empty constructor
  // so hive can generate(serializable) object
  // so you u can store this object in local db (hive)
  UserModel(
      {required this.username,
      required this.isSuperuser,
      required this.email,
      required this.name,
      required this.userId,
      required this.accessToken});
}
