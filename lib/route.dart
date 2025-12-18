import 'package:flutter/material.dart';
import 'package:fx_tutor/widgets/screens/auth/login_screen.dart';
import 'package:fx_tutor/widgets/screens/auth/register_screen.dart';
import 'package:fx_tutor/widgets/screens/home/home_screen.dart';
import 'package:fx_tutor/widgets/screens/splash/splash_screen.dart';

Route<dynamic>? mainRoute(RouteSettings settings) {
  switch (settings.name) {
    case SplashScreen.route:
      return MaterialPageRoute(builder: (context) => const SplashScreen());
    case LoginScreen.route:
      return MaterialPageRoute(builder: (context) => LoginScreen());
    case RegisterScreen.route:
      return MaterialPageRoute(builder: (context) => RegisterScreen());
    case HomeScreen.route:
      return MaterialPageRoute(builder: (context) => HomeScreen());
    default:
      return MaterialPageRoute(builder: (context) => LoginScreen());
  }
}
