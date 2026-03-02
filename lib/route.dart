import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fx_tutor/models/calculator_guide_model.dart';
import 'package:fx_tutor/models/learning_content.dart';
import 'package:fx_tutor/widgets/screens/auth/login_screen.dart';
import 'package:fx_tutor/widgets/screens/auth/register_screen.dart';
import 'package:fx_tutor/widgets/screens/caculator/calculator_screen.dart';
import 'package:fx_tutor/widgets/screens/content_manager/content_manager_screen.dart';
import 'package:fx_tutor/widgets/screens/content_manager/contribute_content/admin_contribute_screen.dart';
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
import 'package:fx_tutor/widgets/screens/contribute/contribute_screen.dart';
import 'package:fx_tutor/widgets/screens/guide/guide_screen.dart';
import 'package:fx_tutor/widgets/screens/home/home_screen.dart';
import 'package:fx_tutor/widgets/screens/home/learning_list_detail_screen.dart';
import 'package:fx_tutor/widgets/screens/home/learning_list_screen.dart';
import 'package:fx_tutor/widgets/screens/home/quiz_screen.dart';
import 'package:fx_tutor/widgets/screens/home/topic_list_screen.dart';
import 'package:fx_tutor/widgets/screens/info/info_screen.dart';
import 'package:fx_tutor/widgets/screens/splash/splash_screen.dart';
import 'package:fx_tutor/widgets/screens/user_manager/user_manager_screen.dart';

Route<dynamic>? mainRoute(RouteSettings settings) {
  switch (settings.name) {
    case SplashScreen.route:
      return MaterialPageRoute(builder: (context) => const SplashScreen(), settings: settings);
    case LoginScreen.route:
      return MaterialPageRoute(builder: (context) => LoginScreen(), settings: settings);
    case RegisterScreen.route:
      return MaterialPageRoute(builder: (context) => RegisterScreen(), settings: settings);
    case HomeScreen.route:
      return MaterialPageRoute(builder: (context) => HomeScreen(), settings: settings);
    case TopicListScreen.route:
      return MaterialPageRoute(builder: (context) => const TopicListScreen(), settings: settings);
    case ContentManagerScreen.route:
      return MaterialPageRoute(builder: (context) => ContentManagerScreen(), settings: settings);
    case LearningContentManagerScreen.route:
      return MaterialPageRoute(
        builder: (context) => LearningContentManagerScreen(),
        settings: settings,
      );

    case GuideContentManagerScreen.route:
      return MaterialPageRoute(
        builder: (context) => GuideContentManagerScreen(),
        settings: settings,
      );
    case AdminContributeScreen.route:
      return MaterialPageRoute(
        builder: (context) => AdminContributeScreen(),
        settings: settings,
      );
    case AddTopicScreen.route:
      var cubit = (settings.arguments as Map<String, dynamic>)['cubit'] as TopicCubit;
      var isAddMode = (settings.arguments as Map<String, dynamic>)['isAddMode'] as bool;
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => BlocProvider.value(
          value: cubit,
          child: AddTopicScreen(isAddMode),
        ),
      );
    case LearningContentScreen.route:
      var cubit = (settings.arguments as Map<String, dynamic>)['cubit'] as TopicCubit;
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => BlocProvider.value(
          value: cubit,
          child: const LearningContentScreen(),
        ),
      );

    case GuideContentScreen.route:
      var cubit = (settings.arguments as Map<String, dynamic>)['cubit'] as TopicCubit;
      return MaterialPageRoute(
        settings: settings,
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
        settings: settings,
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
        settings: settings,
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
        settings: settings,
        builder: (context) => GuideDetailScreen(guide: guide),
      );

    case LearningDetailScreen.route:
      var content = settings.arguments as LearningContent;
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => LearningDetailScreen(content: content),
      );
    case LearningListScreen.route:
      var cubit = (settings.arguments as Map<String, dynamic>)['cubit'] as TopicCubit;
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => BlocProvider.value(
          value: cubit,
          child: const LearningListScreen(),
        ),
      );
    case LearningListDetailScreen.route:
      var content = settings.arguments as LearningContent;
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => LearningListDetailScreen(content: content),
      );
    case QuizScreen.route:
      var content = settings.arguments as LearningContent;
      return MaterialPageRoute(
        builder: (context) => QuizScreen(
          content: content,
        ),
        settings: settings,
      );
    case CalculatorScreen.route:
      return MaterialPageRoute(builder: (context) => CalculatorScreen(), settings: settings);
    case ContributeScreen.route:
      return MaterialPageRoute(builder: (context) => ContributeScreen(), settings: settings);
    case GuideScreen.route:
      return MaterialPageRoute(builder: (context) => GuideScreen(), settings: settings);
    case InfoScreen.route:
      return MaterialPageRoute(builder: (context) => InfoScreen(), settings: settings);
    case UserManagerScreen.route:
      return MaterialPageRoute(builder: (context) => UserManagerScreen(), settings: settings);
    default:
      return MaterialPageRoute(builder: (context) => LoginScreen(), settings: settings);
  }
}
