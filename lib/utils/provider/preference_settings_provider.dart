import 'package:flutter/material.dart';

class PreferenceSettingsProvider with ChangeNotifier {
  bool _isDarkTheme = false;

  bool get isDarkTheme => _isDarkTheme;

  void enableDarkTheme(bool isEnabled) {
    _isDarkTheme = isEnabled;
    notifyListeners();
  }
}
