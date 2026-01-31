import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fx_tutor/models/calculator_guide_model.dart';
import 'package:fx_tutor/models/learning_content.dart';
import 'package:fx_tutor/widgets/screens/auth/login_screen.dart';
import 'package:fx_tutor/widgets/screens/auth/register_screen.dart';
import 'package:fx_tutor/widgets/screens/content_manager/content_manager_screen.dart';
import 'package:fx_tutor/widgets/screens/content_manager/guide_content/add_guide_content_screen.dart';
import 'package:fx_tutor/widgets/screens/content_manager/guide_content/guide_content_manager_screen.dart';
import 'package:fx_tutor/widgets/screens/content_manager/guide_content/guide_content_screen.dart';
import 'package:fx_tutor/widgets/screens/content_manager/guide_content/guide_detail_screen.dart';
import 'package:fx_tutor/widgets/screens/content_manager/guide_content/guide_manage_cubit.dart';
import 'package:fx_tutor/widgets/screens/content_manager/learning_content/add_learning_content_screen.dart';
import 'package:fx_tutor/widgets/screens/content_manager/learning_content/add_topic_screen.dart';
import 'package:fx_tutor/widgets/screens/content_manager/learning_content/learning_content_cubit.dart';
import 'package:fx_tutor/widgets/screens/content_manager/learning_content/learning_content_manager_screen.dart';
import 'package:fx_tutor/widgets/screens/content_manager/learning_content/learning_content_screen.dart';
import 'package:fx_tutor/widgets/screens/content_manager/learning_content/learning_detail_screen.dart';
import 'package:fx_tutor/widgets/screens/content_manager/learning_content/topic_cubit.dart';
import 'package:fx_tutor/widgets/screens/home/home_screen.dart';
import 'package:fx_tutor/widgets/screens/home/learning_list_detail_screen.dart';
import 'package:fx_tutor/widgets/screens/home/learning_list_screen.dart';
import 'package:fx_tutor/widgets/screens/home/topic_list_screen.dart';
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
    case TopicListScreen.route:
      return MaterialPageRoute(builder: (context) => const TopicListScreen());
    case ContentManagerScreen.route:
      return MaterialPageRoute(builder: (context) => ContentManagerScreen());
    case LearningContentManagerScreen.route:
      return MaterialPageRoute(builder: (context) => LearningContentManagerScreen());

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

    case AddLearningContentScreen.route:
      var topicCubit = (settings.arguments as Map<String, dynamic>)['topicCubit'] as TopicCubit;
      var learningCubit =
          (settings.arguments as Map<String, dynamic>)['learningCubit'] as LearningCubit;
      var isAddMode = (settings.arguments as Map<String, dynamic>)['isAddMode'] as bool;
      var editIndex = (settings.arguments as Map<String, dynamic>)['editIndex'] as int?;

      return MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: topicCubit),
            BlocProvider.value(value: learningCubit),
          ],
          child: AddLearningContentScreen(
            isAddMode: isAddMode,
            editIndex: editIndex,
          ),
        ),
      );

    case GuideDetailScreen.route:
      var guide = settings.arguments as CalculatorGuideModel;
      return MaterialPageRoute(
        builder: (context) => GuideDetailScreen(guide: guide),
      );

    case LearningDetailScreen.route:
      var content = settings.arguments as LearningContent;
      return MaterialPageRoute(
        builder: (context) => LearningDetailScreen(content: content),
      );
    case LearningListScreen.route:
      var cubit = (settings.arguments as Map<String, dynamic>)['cubit'] as TopicCubit;
      return MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: cubit,
          child: const LearningListScreen(),
        ),
      );
    case LearningListDetailScreen.route:
      var content = settings.arguments as LearningContent;
      return MaterialPageRoute(
        builder: (context) => LearningListDetailScreen(content: content),
      );
    default:
      return MaterialPageRoute(builder: (context) => LoginScreen());
  }
}
