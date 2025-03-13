import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../app/data/local/my_shared_pref.dart';
import 'dark_theme_colors.dart';
import 'light_theme_colors.dart';
import 'my_styles.dart';
import 'theme_extensions/employee_list_item_theme_data.dart';

class MyTheme {
  static getThemeData({required bool isLight}){
    return ThemeData(
      // main color (app bar,tabs..etc)
        primaryColor: isLight ? LightThemeColors.primaryColor : DarkThemeColors.primaryColor,

        // secondary & background color
        colorScheme: ColorScheme.fromSwatch(
          accentColor: isLight ? LightThemeColors.accentColor : DarkThemeColors.accentColor,
          backgroundColor: isLight ? LightThemeColors.backgroundColor : DarkThemeColors.backgroundColor,
          brightness: isLight ? Brightness.light : Brightness.dark,
        )
            .copyWith(
          secondary: isLight ? LightThemeColors.accentColor : DarkThemeColors.accentColor,
        ),

        // color contrast (if the theme is dark text should be white for example)
        brightness: isLight ? Brightness.light : Brightness.dark,

        // card widget background color
        cardColor: isLight ? LightThemeColors.cardColor : DarkThemeColors.cardColor,

        // hint text color
        hintColor: isLight ? LightThemeColors.hintTextColor : DarkThemeColors.hintTextColor,

        // divider color
        dividerColor: isLight ? LightThemeColors.dividerColor : DarkThemeColors.dividerColor,

        // app background color
        scaffoldBackgroundColor: isLight ? LightThemeColors.scaffoldBackgroundColor : DarkThemeColors.scaffoldBackgroundColor,

        // progress bar theme
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: isLight ? LightThemeColors.primaryColor : DarkThemeColors.primaryColor,
        ),

        // appBar theme
        appBarTheme: MyStyles.getAppBarTheme(isLightTheme: isLight),

        // elevated button theme
        elevatedButtonTheme: MyStyles.getElevatedButtonTheme(isLightTheme: isLight),

        // text theme
        textTheme: MyStyles.getTextTheme(isLightTheme: isLight),

        // chip theme
        chipTheme: MyStyles.getChipTheme(isLightTheme: isLight),

        // icon theme
        iconTheme: MyStyles.getIconTheme(isLightTheme: isLight),

        // list tile theme
        listTileTheme: MyStyles.getListTileThemeData(isLightTheme: isLight),

        // custom themes
        extensions: [
          MyStyles.getHeaderContainerTheme(isLightTheme: isLight),
          MyStyles.getEmployeeListItemTheme(isLightTheme: isLight),
        ]
    );
  }

  /// update app theme and save theme type to shared pref
  /// (so when the app is killed and up again theme will remain the same)
  static changeTheme(){
    // *) check if the current theme is light (default is light)
    bool isLightTheme = MySharedPref.getThemeIsLight();

    // *) store the new theme mode on get storage
    MySharedPref.setThemeIsLight(!isLightTheme);

    // *) let GetX change theme
    Get.changeThemeMode(!isLightTheme ? ThemeMode.light : ThemeMode.dark);
  }

  /// check if the theme is light or dark
  bool get getThemeIsLight => MySharedPref.getThemeIsLight();
}

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF416FDF),
  onPrimary: Color(0xFFFFFFFF),
  secondary: Color(0xFF6EAEE7),
  onSecondary: Color(0xFFFFFFFF),
  error: Color(0xFFBA1A1A),
  onError: Color(0xFFFFFFFF),
  background: Color(0xFFFCFDF6),
  onBackground: Color(0xFF1A1C18),
  shadow: Color(0xFF000000),
  outlineVariant: Color(0xFFC2C8BC),
  surface: Color(0xFFF9FAF3),
  onSurface: Color(0xFF1A1C18),
);

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF416FDF),
  onPrimary: Color(0xFFFFFFFF),
  secondary: Color(0xFF6EAEE7),
  onSecondary: Color(0xFFFFFFFF),
  error: Color(0xFFBA1A1A),
  onError: Color(0xFFFFFFFF),
  background: Color(0xFFFCFDF6),
  onBackground: Color(0xFF1A1C18),
  shadow: Color(0xFF000000),
  outlineVariant: Color(0xFFC2C8BC),
  surface: Color(0xFFF9FAF3),
  onSurface: Color(0xFF1A1C18),
);

ThemeData lightMode = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: lightColorScheme,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(
        lightColorScheme.primary, // Slightly darker shade for the button
      ),
      foregroundColor:
          MaterialStateProperty.all<Color>(Colors.white), // text color
      elevation: MaterialStateProperty.all<double>(5.0), // shadow
      padding: MaterialStateProperty.all<EdgeInsets>(
          const EdgeInsets.symmetric(horizontal: 20, vertical: 18)),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Adjust as needed
        ),
      ),
    ),
  ),
);

ThemeData darkMode = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: darkColorScheme,
);