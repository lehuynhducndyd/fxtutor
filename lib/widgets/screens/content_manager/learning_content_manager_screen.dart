import 'package:flutter/material.dart';

class LearningContentManagerScreen extends StatefulWidget {
  const LearningContentManagerScreen({super.key});
  static const String route = 'LearningContentManagerScreen';

  @override
  State<LearningContentManagerScreen> createState() => _LearningContentManagerScreenState();
}

class _LearningContentManagerScreenState extends State<LearningContentManagerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nội dung học"),
      ),
      body: Center(
        child: Text("learning"),
      ),
    );
  }
}
