import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FayzoxStore extends ChangeNotifier {
  SharedPreferences? _prefs;
  List<dynamic> _palettes = [];

  List<dynamic> get palettes => _palettes;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final data = _prefs?.getString('fayzox_data');
    if (data != null) {
      _palettes = jsonDecode(data);
    }
    notifyListeners();
  }

  void addPalette(String item) {
    _palettes.add(item);
    _prefs?.setString('fayzox_data', jsonEncode(_palettes));
    notifyListeners();
  }
}
