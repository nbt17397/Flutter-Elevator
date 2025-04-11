import 'package:elevator/app/modules/authentication/my_authentication.dart';
import 'package:elevator/app/services/request_location_permission.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'app/data/local/my_hive.dart';
import 'app/data/local/my_shared_pref.dart';
import 'app/data/models/user_model.dart';
import 'app/modules/authentication/bloc/authentication_bloc.dart';
import 'app/services/mqtt/mqtt_provider.dart';
import 'app/services/mqtt/mqtt_service.dart';
// import 'utils/fcm_helper.dart';
// import 'package:getx_skeleton/utils/awesome_notifications_helper.dart';

Future<void> main() async {
  // wait for bindings
  WidgetsFlutterBinding.ensureInitialized();
  await checkAndRequestLocationPermission();
  final mqttService = MqttService();
  // initialize local db (hive) and register our custom adapters
  await MyHive.init(registerAdapters: (hive) {
    hive.registerAdapter(UserModelAdapter());
  });

  // init shared preference
  await MySharedPref.init();
  await Hive.openBox<UserModel>('userModel');

  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));

  runApp(MultiBlocProvider(providers: [
    ChangeNotifierProvider(
      create: (context) => MqttProvider(mqttService),
      lazy: false,
    ),
    BlocProvider(create: (context) => AuthenticationBloc()),
  ], child: const MyAuthentication()));
}
