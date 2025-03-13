import 'package:get/get.dart';
import '../modules/auth/login_screen.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;
  static const AUTH = Routes.AUTH;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const LoginScreen(),
      // binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.AUTH,
      page: () => LoginScreen(),
      // binding: AuthBinding(),
    ),
  ];
}
