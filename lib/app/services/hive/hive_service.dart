import '../../data/models/user_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveServie {
  static Future<UserModel?> getUserModel() async {
    Box<UserModel> _userModel = await Hive.openBox<UserModel>('userModel');

    return _userModel.get(0);
  }
}
