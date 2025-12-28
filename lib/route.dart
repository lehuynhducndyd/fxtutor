import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fx_tutor/widgets/screens/auth/login_screen.dart';
import 'package:fx_tutor/widgets/screens/auth/register_screen.dart';
import 'package:fx_tutor/widgets/screens/content_manager/content_manager_screen.dart';
import 'package:fx_tutor/widgets/screens/content_manager/learning_content/add_topic_screen.dart';
import 'package:fx_tutor/widgets/screens/content_manager/learning_content/learning_content_manager_screen.dart';
import 'package:fx_tutor/widgets/screens/content_manager/learning_content/list_math_types_screen.dart';
import 'package:fx_tutor/widgets/screens/content_manager/learning_content/topic_cubit.dart';
import 'package:fx_tutor/widgets/screens/content_manager/manual_content/manual_content_manager_screen.dart';
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
    case ContentManagerScreen.route:
      return MaterialPageRoute(builder: (context) => ContentManagerScreen());
    case LearningContentManagerScreen.route:
      return MaterialPageRoute(builder: (context) => LearningContentManagerScreen());
    case ManualContentManagerScreen.route:
      return MaterialPageRoute(builder: (context) => ManualContentManagerScreen());
    case AddTopicScreen.route:
      var cubit = (settings.arguments as Map<String, dynamic>)['cubit'] as TopicCubit;
      var isAddMode = (settings.arguments as Map<String, dynamic>)['isAddMode'] as bool;
      return MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: cubit,
          child: AddTopicScreen(isAddMode),
        ),
      );
    case ListMathTypesScreen.route:
      var cubit = (settings.arguments as Map<String, dynamic>)['cubit'] as TopicCubit;
      return MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: cubit,
          child: ListMathTypesScreen(),
        ),
      );
    default:
      return MaterialPageRoute(builder: (context) => LoginScreen());
  }
}
