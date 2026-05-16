import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TemaProvider extends ChangeNotifier {
  bool _karanlik = true;

  bool get karanlik => _karanlik;
  ThemeMode get themeMode => _karanlik ? ThemeMode.dark : ThemeMode.light;

  TemaProvider() {
    _yukle();
  }

  Future<void> _yukle() async {
    final prefs = await SharedPreferences.getInstance();
    _karanlik = prefs.getBool('karanlik_tema') ?? true;
    notifyListeners();
  }

  Future<void> toggle() async {
    _karanlik = !_karanlik;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('karanlik_tema', _karanlik);
  }
}
