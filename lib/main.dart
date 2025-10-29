import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'design_system/theme.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );

  runApp(const GrocliApp());
}

class GrocliApp extends StatefulWidget {
  const GrocliApp({super.key});

  @override
  State<GrocliApp> createState() => _GrocliAppState();
}

class _GrocliAppState extends State<GrocliApp> {
  bool _hasCompletedOnboarding = false;

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoApp(
        title: 'Grocli',
        theme: GrocliTheme.cupertinoTheme(),
        home: _hasCompletedOnboarding
            ? const HomeScreen()
            : OnboardingScreen(
                onComplete: () {
                  setState(() {
                    _hasCompletedOnboarding = true;
                  });
                },
              ),
        debugShowCheckedModeBanner: false,
      );
    }

    return MaterialApp(
      title: 'Grocli',
      theme: GrocliTheme.lightTheme(),
      darkTheme: GrocliTheme.darkTheme(),
      themeMode: ThemeMode.system,
      home: _hasCompletedOnboarding
          ? const HomeScreen()
          : OnboardingScreen(
              onComplete: () {
                setState(() {
                  _hasCompletedOnboarding = true;
                });
              },
            ),
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: MediaQuery.of(context).textScaler.clamp(
              minScaleFactor: 0.8,
              maxScaleFactor: 2.0,
            ),
          ),
          child: child!,
        );
      },
    );
  }
}
