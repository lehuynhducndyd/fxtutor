import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../main_cubit.dart';

class SettingScreen extends StatefulWidget {
  static const String route = 'SettingScreen';

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainCubit, MainState>(
      builder: (context, state) {
        int isLightTheme = state.isLightTheme ? 1 : -1;
        return Container(
          padding: EdgeInsets.all(16),
          alignment: Alignment.topCenter,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Giao diện",
                    style: TextStyle(fontSize: 16),
                  ),
                  RadioListTile(
                    title: Text('Sáng'),
                    value: 1,
                    groupValue: isLightTheme,
                    onChanged: (value) {
                      setState(() {
                        isLightTheme = 1;
                        context.read<MainCubit>().setTheme(true);
                      });
                    },
                  ),
                  RadioListTile(
                    title: Text('Tối'),
                    value: -1,
                    groupValue: isLightTheme,
                    onChanged: (value) {
                      setState(() {
                        isLightTheme = -1;
                        context.read<MainCubit>().setTheme(false);
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
