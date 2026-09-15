import 'package:flutter/material.dart';
import 'theme/fayzox_theme.dart';
import 'painters/gradient_wheel_painter.dart';

class FayzoxApp extends StatefulWidget {
  const FayzoxApp({super.key});

  @override
  State<FayzoxApp> createState() => _FayzoxAppState();
}

class _FayzoxAppState extends State<FayzoxApp> {
  final ValueNotifier<Color> _selectedColor = ValueNotifier<Color>(const Color(0xFFA855F7));
  final ValueNotifier<double> _gradientAngle = ValueNotifier<double>(45.0);

  final List<Color> _palettePresets = const [
    Color(0xFFA855F7), // Purple
    Color(0xFF3B82F6), // Blue
    Color(0xFF10B981), // Emerald
    Color(0xFFF59E0B), // Amber
    Color(0xFFEF4444), // Crimson
    Color(0xFF06B6D4), // Cyan
  ];

  @override
  void dispose() {
    _selectedColor.dispose();
    _gradientAngle.dispose();
    super.dispose();
  }

  List<Color> _generateShadeRamp(Color base) {
    final hsl = HSLColor.fromColor(base);
    return List.generate(10, (i) {
      final lightness = ((i + 1) * 0.09).clamp(0.05, 0.95);
      return hsl.withLightness(lightness).toColor();
    });
  }

  String _toHex(Color c) {
    final r = (c.r * 255).round().toRadixString(16).padLeft(2, '0');
    final g = (c.g * 255).round().toRadixString(16).padLeft(2, '0');
    final b = (c.b * 255).round().toRadixString(16).padLeft(2, '0');
    return '#${r.toUpperCase()}${g.toUpperCase()}${b.toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fayzox Studio',
      debugShowCheckedModeBanner: false,
      theme: FayzoxTheme.themeData,
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'FAYZOX SHADE STUDIO',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 16),
            ),
            bottom: const TabBar(
              labelColor: FayzoxTheme.accent,
              unselectedLabelColor: Colors.grey,
              indicatorColor: FayzoxTheme.accent,
              indicatorWeight: 3,
              tabs: [
                Tab(icon: Icon(Icons.palette_outlined), text: 'Shade Ramp'),
                Tab(icon: Icon(Icons.gradient), text: 'Gradient'),
                Tab(icon: Icon(Icons.code), text: 'Code Export'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _buildRampTab(),
              _buildGradientTab(),
              _buildExportTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRampTab() {
    return ValueListenableBuilder<Color>(
      valueListenable: _selectedColor,
      builder: (context, baseColor, _) {
        final shades = _generateShadeRamp(baseColor);
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Base Accent',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: FayzoxTheme.ink),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _palettePresets.map((c) {
                  final isSelected = c.toARGB32() == baseColor.toARGB32();
                  return GestureDetector(
                    onTap: () => _selectedColor.value = c,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? FayzoxTheme.ink : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Text(
                '10-Step Monochromatic Ramp (${_toHex(baseColor)})',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: shades.length,
                itemBuilder: (context, idx) {
                  final shade = shades[idx];
                  final hex = _toHex(shade);
                  final lightness = ((idx + 1) * 10);
                  final isDark = idx < 5;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: shade,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Step ${idx + 1} ($lightness%)',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          hex,
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGradientTab() {
    return ValueListenableBuilder<Color>(
      valueListenable: _selectedColor,
      builder: (context, baseColor, _) {
        return ValueListenableBuilder<double>(
          valueListenable: _gradientAngle,
          builder: (context, angle, _) {
            final hsl = HSLColor.fromColor(baseColor);
            final complementary = hsl.withHue((hsl.hue + 180) % 360).toColor();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [baseColor, complementary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Angle ${angle.round()}° Linear Gradient',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: SizedBox(
                      width: 200,
                      height: 200,
                      child: CustomPaint(
                        painter: GradientWheelPainter(
                          baseColor: baseColor,
                          angleDegrees: angle,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Rotation Angle: ${angle.round()}°'),
                  Slider(
                    value: angle,
                    min: 0,
                    max: 360,
                    activeColor: FayzoxTheme.accent,
                    onChanged: (val) => _gradientAngle.value = val,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildExportTab() {
    return ValueListenableBuilder<Color>(
      valueListenable: _selectedColor,
      builder: (context, baseColor, _) {
        final shades = _generateShadeRamp(baseColor);
        final flutterCode = StringBuffer('// Flutter Color Tokens\n');
        for (int i = 0; i < shades.length; i++) {
          final hex = _toHex(shades[i]).replaceFirst('#', '0xFF');
          flutterCode.writeln('const colorStep${(i + 1) * 100} = Color($hex);');
        }

        final cssCode = StringBuffer(':root {\n');
        for (int i = 0; i < shades.length; i++) {
          cssCode.writeln('  --shade-${(i + 1) * 100}: ${_toHex(shades[i])};');
        }
        cssCode.writeln('}');

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Flutter Palette Code', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E2E),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  flutterCode.toString(),
                  style: const TextStyle(color: Color(0xFFA6ACCD), fontFamily: 'monospace', fontSize: 12),
                ),
              ),
              const SizedBox(height: 20),
              const Text('CSS Variables', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E2E),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  cssCode.toString(),
                  style: const TextStyle(color: Color(0xFFA6ACCD), fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
