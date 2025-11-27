import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shadow_mon_app/provider/game_provider.dart';
import 'package:shadow_mon_app/screen/home_page.dart';

// --- MAIN ENTRY POINT ---
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
      ],
      child: const ShadowMonApp(),
    ),
  );
}

class ShadowMonApp extends StatelessWidget {
  const ShadowMonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShadowMon',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: const Color(0xFFF2F2F2),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}








