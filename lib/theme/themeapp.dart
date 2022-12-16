import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Function fu;
ThemeData obj;
Future<void> changetheme() async {
  if (obj == ThemeData.light()) {
    print("light to dark");
    obj = ThemeData.dark();
    var p = await SharedPreferences.getInstance();
    await p.setBool("dark", true);
    fu(true);
  } else {
    print("dark to light");
    obj = ThemeData.light();
    var p = await SharedPreferences.getInstance();
    await p.setBool("dark", false);
    fu(false);
  }
}

ThemeData playtheme(Function f, bool dark) {
  fu = f;
  if (dark == true) {
    obj = ThemeData.dark();
  } else {
    obj = ThemeData.light();
  }
  return themeofapp(obj);
}

ThemeData themeofapp(ThemeData base) {
  TextTheme _texttheme(TextTheme base) {
    return base.copyWith(
        headline1: base.headline1.copyWith(
      fontFamily: 'Roboto',
      fontSize: 20,
      color: Colors.black,
    ));
  }

  return base.copyWith(
      snackBarTheme: SnackBarThemeData(
          backgroundColor: Colors.indigo,
          contentTextStyle: TextStyle(color: Colors.white)),
      textTheme: _texttheme(base.textTheme),
      primaryColor: Colors.purple,
      accentColor: Colors.orange,
      floatingActionButtonTheme:
          FloatingActionButtonThemeData(backgroundColor: Colors.amber));
}
