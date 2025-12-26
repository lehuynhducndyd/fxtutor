import 'package:flutter/material.dart';

class ManualContentManagerScreen extends StatefulWidget {
  const ManualContentManagerScreen({super.key});
  static const String route = 'ManualContentManagerScreen';

  @override
  State<ManualContentManagerScreen> createState() => _ManualContentManagerScreenState();
}

class _ManualContentManagerScreenState extends State<ManualContentManagerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nội dung hd"),
      ),
      body: Center(
        child: Text("manual"),
      ),
    );
  }
}
