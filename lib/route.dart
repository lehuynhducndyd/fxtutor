import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fx_tutor/widgets/screens/auth/login_screen.dart';
import 'package:fx_tutor/widgets/screens/auth/register_screen.dart';
import 'package:fx_tutor/widgets/screens/content_manager/content_manager_screen.dart';
import 'package:fx_tutor/widgets/screens/content_manager/guide_content/add_guide_content_screen.dart';
import 'package:fx_tutor/widgets/screens/content_manager/guide_content/guide_content_manager_screen.dart';
import 'package:fx_tutor/widgets/screens/content_manager/guide_content/guide_content_screen.dart';
import 'package:fx_tutor/widgets/screens/content_manager/guide_content/guide_manage_cubit.dart';
import 'package:fx_tutor/widgets/screens/content_manager/learning_content/add_topic_screen.dart';
import 'package:fx_tutor/widgets/screens/content_manager/learning_content/learning_content_manager_screen.dart';
import 'package:fx_tutor/widgets/screens/content_manager/learning_content/learning_content_screen.dart';
import 'package:fx_tutor/widgets/screens/content_manager/learning_content/topic_cubit.dart';
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

    // Sửa Manual thành Guide
    case GuideContentManagerScreen.route:
      return MaterialPageRoute(builder: (context) => GuideContentManagerScreen());

    case AddTopicScreen.route:
      var cubit = (settings.arguments as Map<String, dynamic>)['cubit'] as TopicCubit;
      var isAddMode = (settings.arguments as Map<String, dynamic>)['isAddMode'] as bool;
      return MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: cubit,
          child: AddTopicScreen(isAddMode),
        ),
      );
    case LearningContentScreen.route:
      var cubit = (settings.arguments as Map<String, dynamic>)['cubit'] as TopicCubit;
      return MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: cubit,
          child: const LearningContentScreen(),
        ),
      );

    // Sửa Manual thành Guide
    case GuideContentScreen.route:
      var cubit = (settings.arguments as Map<String, dynamic>)['cubit'] as TopicCubit;
      return MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: cubit,
          child: const GuideContentScreen(),
        ),
      );
    case AddGuideContentScreen.route:
      var topicCubit = (settings.arguments as Map<String, dynamic>)['topicCubit'] as TopicCubit;
      var guideCubit =
          (settings.arguments as Map<String, dynamic>)['guideCubit'] as GuideManageCubit;
      var isAddMode = (settings.arguments as Map<String, dynamic>)['isAddMode'] as bool;
      var editIndex = (settings.arguments as Map<String, dynamic>)['editIndex'] as int?;

      return MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: topicCubit),
            BlocProvider.value(value: guideCubit),
          ],
          child: AddGuideContentScreen(
            isAddMode: isAddMode,
            editIndex: editIndex,
          ),
        ),
      );
    default:
      return MaterialPageRoute(builder: (context) => LoginScreen());
  }
}
