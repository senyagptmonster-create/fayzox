import 'dart:math' as math;
import 'package:flutter/material.dart';

class ColorShade {
  final int step; // 50, 100, 200, ... 900
  final Color color;
  final String hexCode;
  final double contrastWithWhite;
  final double contrastWithBlack;

  ColorShade({
    required this.step,
    required this.color,
    required this.hexCode,
    required this.contrastWithWhite,
    required this.contrastWithBlack,
  });

  Map<String, dynamic> toJson() => {
        'step': step,
        'hexCode': hexCode,
      };

  factory ColorShade.fromHex(int step, String hex) {
    final cleanHex = hex.replaceAll('#', '').trim();
    final intColor = int.parse('FF$cleanHex', radix: 16);
    final c = Color(intColor);
    return ColorShade(
      step: step,
      color: c,
      hexCode: '#${cleanHex.toUpperCase()}',
      contrastWithWhite: ShadeEngine.calculateContrast(c, Colors.white),
      contrastWithBlack: ShadeEngine.calculateContrast(c, Colors.black),
    );
  }
}

class PaletteRamp {
  final String id;
  final String name;
  final Color baseColor;
  final List<ColorShade> shades;
  final DateTime createdAt;

  PaletteRamp({
    required this.id,
    required this.name,
    required this.baseColor,
    required this.shades,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'baseHex': '#${baseColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
        'createdAt': createdAt.toIso8601String(),
        'shades': shades.map((s) => s.toJson()).toList(),
      };

  factory PaletteRamp.fromJson(Map<String, dynamic> json) {
    final baseHex = (json['baseHex'] as String).replaceAll('#', '');
    final baseColor = Color(int.parse('FF$baseHex', radix: 16));
    final shadeList = (json['shades'] as List<dynamic>)
        .map((item) => ColorShade.fromHex(
              item['step'] as int,
              item['hexCode'] as String,
            ))
        .toList();

    return PaletteRamp(
      id: json['id'] as String,
      name: json['name'] as String,
      baseColor: baseColor,
      shades: shadeList,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class ShadeEngine {
  ShadeEngine._();

  static const List<int> steps = [50, 100, 200, 300, 400, 500, 600, 700, 800, 900];

  /// Computes relative luminance according to WCAG 2.1 specs
  static double relativeLuminance(Color color) {
    double transform(double val) {
      return val <= 0.03928 ? val / 12.92 : math.pow((val + 0.055) / 1.055, 2.4).toDouble();
    }

    final r = transform(color.r);
    final g = transform(color.g);
    final b = transform(color.b);
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// Calculates contrast ratio between two colors (range: 1.0 to 21.0)
  static double calculateContrast(Color foreground, Color background) {
    final lum1 = relativeLuminance(foreground);
    final lum2 = relativeLuminance(background);
    final lighter = math.max(lum1, lum2);
    final darker = math.min(lum1, lum2);
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Formats a Color to #RRGGBB
  static String toHex(Color color) {
    final val = color.toARGB32();
    return '#${val.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  /// Parse hex string to Color
  static Color? parseHex(String input) {
    try {
      var clean = input.replaceAll('#', '').trim();
      if (clean.length == 3) {
        clean = clean.split('').map((c) => '$c$c').join();
      }
      if (clean.length == 6) {
        return Color(int.parse('FF$clean', radix: 16));
      }
    } catch (_) {}
    return null;
  }

  /// Generates a smooth 10-step monochromatic ramp from step 50 to step 900
  static List<ColorShade> generate10StepRamp(Color baseColor) {
    final hsl = HSLColor.fromColor(baseColor);
    final baseHue = hsl.hue;
    final baseSat = hsl.saturation;

    // Target lightness anchor points for standard design system tokens:
    // 50: 0.96, 100: 0.90, 200: 0.80, 300: 0.70, 400: 0.60
    // 500: base lightness or 0.50, 600: 0.40, 700: 0.30, 800: 0.20, 900: 0.12
    final Map<int, double> targetLightness = {
      50: 0.96,
      100: 0.90,
      200: 0.81,
      300: 0.71,
      400: 0.59,
      500: 0.49,
      600: 0.39,
      700: 0.29,
      800: 0.20,
      900: 0.12,
    };

    return steps.map((step) {
      final targetL = targetLightness[step]!;
      // Adjust saturation slightly: lighter tints have lower saturation to avoid neon wash
      double sat = baseSat;
      if (step <= 100) {
        sat = (baseSat * 0.75).clamp(0.1, 1.0);
      } else if (step >= 800) {
        sat = (baseSat * 0.9).clamp(0.1, 1.0);
      }

      final color = HSLColor.fromAHSL(1.0, baseHue, sat, targetL).toColor();
      return ColorShade(
        step: step,
        color: color,
        hexCode: toHex(color),
        contrastWithWhite: calculateContrast(color, Colors.white),
        contrastWithBlack: calculateContrast(color, Colors.black),
      );
    }).toList();
  }

  /// Exports ramp to CSS Variables
  static String exportCssVariables(String rampName, List<ColorShade> shades) {
    final prefix = rampName.toLowerCase().replaceAll(RegExp(r'\s+'), '-');
    final buffer = StringBuffer(':root {\n');
    for (final shade in shades) {
      buffer.writeln('  --color-$prefix-${shade.step}: ${shade.hexCode};');
    }
    buffer.writeln('}');
    return buffer.toString();
  }

  /// Exports ramp to Flutter MaterialColor code snippet
  static String exportFlutterCode(String rampName, List<ColorShade> shades) {
    final pascal = rampName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    final buffer = StringBuffer();
    buffer.writeln('// Fayzox Studio Generated Palette: $rampName');
    buffer.writeln('class ${pascal}Palette {');
    for (final s in shades) {
      final hexRaw = s.hexCode.replaceAll('#', '');
      buffer.writeln('  static const Color shade${s.step} = Color(0xFF$hexRaw);');
    }
    buffer.writeln('}');
    return buffer.toString();
  }

  /// Exports ramp to SVG Swatches format
  static String exportSvg(String rampName, List<ColorShade> shades) {
    final buffer = StringBuffer();
    buffer.writeln('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1000 120">');
    buffer.writeln('  <!-- Fayzox Palette: $rampName -->');
    for (int i = 0; i < shades.length; i++) {
      final x = i * 100;
      final shade = shades[i];
      buffer.writeln('  <rect x="$x" y="0" width="100" height="90" fill="${shade.hexCode}" />');
      buffer.writeln('  <text x="${x + 50}" y="110" font-family="sans-serif" font-size="12" text-anchor="middle">${shade.step}</text>');
    }
    buffer.writeln('</svg>');
    return buffer.toString();
  }
}
