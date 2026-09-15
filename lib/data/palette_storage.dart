import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/shade_engine.dart';

class PaletteStorage extends ChangeNotifier {
  static const String _keySavedRamps = 'fayzox_saved_ramps';
  static const String _keyBaseColor = 'fayzox_base_color';
  static const String _keyRampName = 'fayzox_ramp_name';

  Color _baseColor = const Color(0xFF6366F1); // Indigo
  String _rampName = 'Indigo Core';
  List<ColorShade> _currentShades = [];
  List<PaletteRamp> _savedRamps = [];

  // Gradient Mixer state
  Color _gradientColorA = const Color(0xFF6366F1);
  Color _gradientColorB = const Color(0xFFEC4899);
  Color _gradientColorC = const Color(0xFF38BDF8);
  bool _useThreePoints = true;
  double _gradientAngle = 45.0; // degrees

  PaletteStorage() {
    _currentShades = ShadeEngine.generate10StepRamp(_baseColor);
    _loadFromStorage();
  }

  Color get baseColor => _baseColor;
  String get rampName => _rampName;
  List<ColorShade> get currentShades => _currentShades;
  List<PaletteRamp> get savedRamps => List.unmodifiable(_savedRamps);

  Color get gradientColorA => _gradientColorA;
  Color get gradientColorB => _gradientColorB;
  Color get gradientColorC => _gradientColorC;
  bool get useThreePoints => _useThreePoints;
  double get gradientAngle => _gradientAngle;

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final baseInt = prefs.getInt(_keyBaseColor);
      if (baseInt != null) {
        _baseColor = Color(baseInt);
      }
      final savedName = prefs.getString(_keyRampName);
      if (savedName != null && savedName.isNotEmpty) {
        _rampName = savedName;
      }
      _currentShades = ShadeEngine.generate10StepRamp(_baseColor);

      final rawList = prefs.getStringList(_keySavedRamps);
      if (rawList != null && rawList.isNotEmpty) {
        _savedRamps = rawList
            .map((str) => PaletteRamp.fromJson(jsonDecode(str) as Map<String, dynamic>))
            .toList();
      } else {
        // Populate default pre-packaged design palettes
        _savedRamps = [
          PaletteRamp(
            id: 'preset-emerald',
            name: 'Emerald Aurora',
            baseColor: const Color(0xFF10B981),
            shades: ShadeEngine.generate10StepRamp(const Color(0xFF10B981)),
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
          ),
          PaletteRamp(
            id: 'preset-amber',
            name: 'Solar Amber',
            baseColor: const Color(0xFFF59E0B),
            shades: ShadeEngine.generate10StepRamp(const Color(0xFFF59E0B)),
            createdAt: DateTime.now().subtract(const Duration(days: 4)),
          ),
        ];
      }
    } catch (e) {
      debugPrint('Error loading palette storage: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<void> setBaseColor(Color color, {String? name}) async {
    _baseColor = color;
    if (name != null) _rampName = name;
    _currentShades = ShadeEngine.generate10StepRamp(_baseColor);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyBaseColor, _baseColor.toARGB32());
    await prefs.setString(_keyRampName, _rampName);
  }

  void setRampName(String name) {
    _rampName = name;
    notifyListeners();
  }

  Future<void> saveCurrentRamp(String name) async {
    final newRamp = PaletteRamp(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim().isEmpty ? 'Custom Ramp ${_savedRamps.length + 1}' : name.trim(),
      baseColor: _baseColor,
      shades: List.from(_currentShades),
      createdAt: DateTime.now(),
    );
    _savedRamps.insert(0, newRamp);
    notifyListeners();
    await _persistRamps();
  }

  Future<void> deleteRamp(String id) async {
    _savedRamps.removeWhere((r) => r.id == id);
    notifyListeners();
    await _persistRamps();
  }

  void loadRampIntoActive(PaletteRamp ramp) {
    _baseColor = ramp.baseColor;
    _rampName = ramp.name;
    _currentShades = List.from(ramp.shades);
    notifyListeners();
  }

  void setGradientColors({
    Color? colorA,
    Color? colorB,
    Color? colorC,
  }) {
    if (colorA != null) _gradientColorA = colorA;
    if (colorB != null) _gradientColorB = colorB;
    if (colorC != null) _gradientColorC = colorC;
    notifyListeners();
  }

  void setGradientAngle(double angle) {
    _gradientAngle = angle.clamp(0.0, 360.0);
    notifyListeners();
  }

  void setUseThreePoints(bool value) {
    _useThreePoints = value;
    notifyListeners();
  }

  Future<void> _persistRamps() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _savedRamps.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList(_keySavedRamps, list);
  }
}
