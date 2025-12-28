import 'package:flutter/material.dart';

class ListMathTypesScreen extends StatefulWidget {
  const ListMathTypesScreen({super.key});
  static const String route = 'DetailTopicScreen';

  @override
  State<ListMathTypesScreen> createState() => _ListMathTypesScreenState();
}

class _ListMathTypesScreenState extends State<ListMathTypesScreen> {
  @override
  Widget build(BuildContext context) {
    return Page();
  }
}

class Page extends StatelessWidget {
  const Page({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Các dạng bài toán"),
      ),
      body: Body(),
    );
  }
}

class Body extends StatelessWidget {
  const Body({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Danh sách Các bài dạng bài toán"));
  }
}
