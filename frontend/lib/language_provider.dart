import 'package:flutter/material.dart';
import 'config.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = Locale(AppConfig.defaultLanguage);

  Locale get locale => _locale;

  void changeLanguage(String languageCode) {
    _locale = Locale(languageCode);
    notifyListeners();
  }
}