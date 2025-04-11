import 'package:dio/dio.dart';
import 'package:elevator/app/modules/home/menu_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../config/theme/my_theme.dart';
import '../../../config/translations/localization_service.dart';
import '../../data/local/my_shared_pref.dart';
import '../../data/models/user_model.dart';
import '../../routes/app_pages.dart';
import '../../services/base_client.dart';
import '../auth/login_screen.dart';
import '../home/home_screen.dart';
import 'bloc/authentication_bloc.dart';
import 'package:get/get.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyAuthentication extends StatefulWidget {
  const MyAuthentication({super.key});

  @override
  State<MyAuthentication> createState() => _MyAuthenticationState();
}

class _MyAuthenticationState extends State<MyAuthentication> {
  late AuthenticationBloc _authenticationBloc;
  @override
  void initState() {
    super.initState();

    ApiProvider.addInterceptor(
      InterceptorsWrapper(onRequest: (options, handler) {
        print(options.data);
        return handler.next(options);
      }, onResponse: (response, handler) {
        print(response);
        if (response.statusCode == 401) {
          print('Shut down: 401');

          _authenticationBloc.add(ShutDown());
        }
        return handler.next(response);
      }),
    );

    _authenticationBloc = AuthenticationBloc();
    _authenticationBloc.add(AppStarted());
  }

  @override
  void dispose() {
    super.dispose();
    _authenticationBloc.close();
    Hive.close();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: true,
      rebuildFactor: (old, data) => true,
      builder: (context, widget) {
        return GetMaterialApp(
          // todo add your app name
          title: "HP-Elevator",
          useInheritedMediaQuery: true,
          debugShowCheckedModeBanner: false,
          builder: (context, widget) {
            bool themeIsLight = MySharedPref.getThemeIsLight();
            return Theme(
              data: MyTheme.getThemeData(isLight: themeIsLight),
              child: MediaQuery(
                // prevent font from scalling (some people use big/small device fonts)
                // but we want our app font to still the same and dont get affected
                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                child: widget!,
              ),
            );
          },
          // initialRoute: AppPages.AUTH, // first screen to show when app is running
          getPages: AppPages.routes, // app screens
          locale: MySharedPref.getCurrentLocal(), // app language
          translations: LocalizationService
              .getInstance(), // localization services in app (controller app language)
          home: BlocListener(
            bloc: _authenticationBloc,
            listener: (BuildContext context, AuthenticationState state) {
              if (state is AuthenticationUnauthenticated) {
                if (state.type == 2) {
                  showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Cảnh báo'),
                          content: const Text(
                              'Phiên đăng nhập đã kết thúc, vui lòng đăng nhập lại.'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.popUntil(
                                    context, ModalRoute.withName('/'));
                              },
                              child: const Text('Đồng ý'),
                            )
                          ],
                        );
                      }).then((_) {
                    if (mounted) {
                      Navigator.popUntil(context, ModalRoute.withName('/'));
                    }
                  });
                }
              }
            },
            child: ValueListenableBuilder(
              valueListenable: Hive.box<UserModel>('userModel').listenable(),
              builder: (context, Box<UserModel> box, _) {
                if (box.values.isEmpty) {
                  return const LoginScreen();
                } else {
                  UserModel userModel = box.getAt(0)!;

                  if (box.containsKey(0)) {
                    ApiProvider.setBearerAuth(userModel.accessToken);
                    return MenuScreen();
                  } else {
                    return const LoginScreen();
                  }
                }
              },
            ),
          ),
        );
      },
    );
  }
}
