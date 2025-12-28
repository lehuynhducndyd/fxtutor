import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fx_tutor/repositories/log.dart';
import 'package:fx_tutor/repositories/log_impl.dart';
import 'package:fx_tutor/repositories/settings_store.dart';
import 'package:fx_tutor/route.dart';
import 'package:fx_tutor/services/auth_service.dart';
import 'package:fx_tutor/services/profile_service.dart';
import 'package:fx_tutor/services/topic_service.dart';
import 'package:fx_tutor/widgets/screens/splash/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'main_cubit.dart';

class SimpleBlocObserver extends BlocObserver {
  final Log log;
  static const String TAG = "Bloc";
  const SimpleBlocObserver(this.log);

  @override
  void onCreate(BlocBase<dynamic> bloc) {
    super.onCreate(bloc);
    log.i(TAG, 'onCreate: ${bloc.runtimeType}');
  }

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    log.i(TAG, 'onEvent: ${bloc.runtimeType}, event: $event');
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    log.i(TAG, 'onChange: ${bloc.runtimeType}, change: ${change.nextState}');
  }

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    log.i(
      TAG,
      'onTransition: ${bloc.runtimeType}, transition: $transition',
    );
  }

  @override
  void onDone(
    Bloc<dynamic, dynamic> bloc,
    Object? event, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    super.onDone(bloc, event, error, stackTrace);
    log.i(
      TAG,
      'onDone: ${bloc.runtimeType}, event: $event, error: $error',
    );
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log.i(TAG, 'onError: ${bloc.runtimeType}, error: $error');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase<dynamic> bloc) {
    super.onClose(bloc);
    log.i(TAG, 'onClose: ${bloc.runtimeType}');
  }
}

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: 'https://hcjqxmmeayigchqpnmnm.supabase.co',
    anonKey: dotenv.env['ANON_KEY'] ?? '',
  );
  Log log = LogImpl();
  Bloc.observer = SimpleBlocObserver(log);
  runApp(
    RepositoryProvider<Log>.value(
      value: log,
      child: Repository(),
    ),
  );
}

class Repository extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthService>(
          create: (context) => AuthService(),
        ),
        RepositoryProvider<TopicService>(
          create: (context) => TopicService(),
        ),
        RepositoryProvider<ProfileService>(
          create: (context) => ProfileService(),
        ),
        RepositoryProvider<SettingsStore>(
          create: (context) => SettingsStore(),
        ),
      ],
      child: Provider(),
    );
  }
}

class Provider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MainCubit(context.read<SettingsStore>())..loadTheme(),
      child: App(),
    );
  }
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainCubit, MainState>(
      builder: (context, state) {
        return MaterialApp(
          darkTheme: ThemeData.dark(),
          theme: ThemeData.light(),
          themeMode: state.isLightTheme ? ThemeMode.light : ThemeMode.dark,
          debugShowCheckedModeBanner: false,
          onGenerateRoute: mainRoute,
          initialRoute: SplashScreen.route,
        );
      },
    );
  }
}
