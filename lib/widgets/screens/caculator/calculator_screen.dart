import 'package:flutter/material.dart';
import 'package:fx_tutor/widgets/screens/caculator/caculator.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});
  static const String route = 'CalculatorScreen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lấy Keylog'),
      ),
      body: KeepAliveWebView(url: 'https://calc-emu.vercel.app/'),
    );
  }
}
