import 'package:flutter/material.dart';
import 'home_screen.dart';

void main() {
  runApp(const LudiApp());
}

class LudiApp extends StatelessWidget {
  const LudiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ludi - Learn Mahjong',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFFC21807),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}
