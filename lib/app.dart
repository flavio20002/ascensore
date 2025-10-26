import 'package:flutter/material.dart';
import 'screens/elevator_control.dart';

class ElevatorApp extends StatefulWidget {
  const ElevatorApp({super.key});

  @override
  State<ElevatorApp> createState() => _ElevatorAppState();
}

class _ElevatorAppState extends State<ElevatorApp> {
  bool _isDarkMode = false;
  String _currentLanguage = 'it';

  void _toggleTheme(bool isDark) {
    setState(() => _isDarkMode = isDark);
  }

  void _changeLanguage(String langCode) {
    setState(() => _currentLanguage = langCode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ascensore a 3 piani',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: ElevatorControl(
        isDarkMode: _isDarkMode,
        onThemeChanged: _toggleTheme,
        currentLanguage: _currentLanguage,
        onLanguageChanged: _changeLanguage,
      ),
    );
  }
}
