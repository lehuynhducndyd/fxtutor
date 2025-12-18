import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/enum/drawer_item.dart';
import '../../../main_cubit.dart';

class MenuScreen extends StatelessWidget {
  static const String route = 'MenuScreen';

  @override
  Widget build(BuildContext context) {
    return Page();
  }
}

class Page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainCubit, MainState>(
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top, 16, 16),
          child: Column(
            children: [
              ListTile(
                title: Text("Học tập"),
                selected: state.selected == DrawerItem.Home,
                trailing: state.selected != DrawerItem.Home ? Icon(Icons.navigate_next) : null,
                onTap: () {
                  context.read<MainCubit>().setSelected(DrawerItem.Home);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text("Cài đặt"),
                selected: state.selected == DrawerItem.Setting,
                trailing: state.selected != DrawerItem.Setting ? Icon(Icons.navigate_next) : null,
                onTap: () {
                  context.read<MainCubit>().setSelected(DrawerItem.Setting);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
