import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../data/palette_storage.dart';
import '../../domain/shade_engine.dart';

class GradientMixerPage extends StatelessWidget {
  const GradientMixerPage({super.key});

  Alignment _getBeginAlignment(double angleDeg) {
    final rad = (angleDeg - 90) * math.pi / 180;
    return Alignment(math.cos(rad), math.sin(rad));
  }

  Alignment _getEndAlignment(double angleDeg) {
    final rad = (angleDeg + 90) * math.pi / 180;
    return Alignment(math.cos(rad), math.sin(rad));
  }

  String _generateCss(double angle, List<Color> colors) {
    final hexList = colors.map((c) => ShadeEngine.toHex(c)).join(', ');
    return 'background: linear-gradient(${angle.round()}deg, $hexList);';
  }

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<PaletteStorage>();
    final colors = storage.useThreePoints
        ? [storage.gradientColorA, storage.gradientColorB, storage.gradientColorC]
        : [storage.gradientColorA, storage.gradientColorB];

    final cssCode = _generateCss(storage.gradientAngle, colors);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.gradient_rounded, color: Color(0xFF8B5CF6)),
            SizedBox(width: 8),
            Text('Gradient Mixer'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Visualizer Canvas
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: _getBeginAlignment(storage.gradientAngle),
                  end: _getEndAlignment(storage.gradientAngle),
                  colors: colors,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.first.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${storage.gradientAngle.round()}°',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Mode Selector: 2-Point vs 3-Point
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.15)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Gradient Complexity',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: false, label: Text('2 Stops')),
                      ButtonSegment(value: true, label: Text('3 Stops')),
                    ],
                    selected: {storage.useThreePoints},
                    onSelectionChanged: (set) => storage.setUseThreePoints(set.first),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Angle Slider Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Rotation Angle',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${storage.gradientAngle.round()}°',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8B5CF6),
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: storage.gradientAngle,
                    min: 0,
                    max: 360,
                    divisions: 72,
                    activeColor: const Color(0xFF8B5CF6),
                    onChanged: (val) => storage.setGradientAngle(val),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('0° (Horizontal)', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      Text('90° (Vertical)', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      Text('180°', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      Text('360°', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Color Stop Pickers
            const Text(
              'COLOR STOPS',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
            const SizedBox(height: 8),

            _buildColorStopTile(
              context,
              'Stop A (Start)',
              storage.gradientColorA,
              (c) => storage.setGradientColors(colorA: c),
            ),
            const SizedBox(height: 8),
            _buildColorStopTile(
              context,
              'Stop B (Middle / End)',
              storage.gradientColorB,
              (c) => storage.setGradientColors(colorB: c),
            ),
            if (storage.useThreePoints) ...[
              const SizedBox(height: 8),
              _buildColorStopTile(
                context,
                'Stop C (End)',
                storage.gradientColorC,
                (c) => storage.setGradientColors(colorC: c),
              ),
            ],
            const SizedBox(height: 16),

            // CSS Code Output
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      cssCode,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 20),
                    tooltip: 'Copy CSS',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: cssCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('CSS gradient copied!')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildColorStopTile(
    BuildContext context,
    String label,
    Color current,
    ValueChanged<Color> onSelected,
  ) {
    final List<Color> swatchChoices = [
      const Color(0xFF6366F1),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFFF43F5E),
      const Color(0xFFF97316),
      const Color(0xFFF59E0B),
      const Color(0xFF10B981),
      const Color(0xFF06B6D4),
      const Color(0xFF0EA5E9),
      const Color(0xFF1E293B),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: current, radius: 10),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const Spacer(),
              Text(
                ShadeEngine.toHex(current),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: swatchChoices.map((c) {
                final isSelected = c.toARGB32() == current.toARGB32();
                return GestureDetector(
                  onTap: () => onSelected(c),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black87 : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
