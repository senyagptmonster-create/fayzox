import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../data/palette_storage.dart';
import '../../domain/shade_engine.dart';

class ShadeGeneratorPage extends StatefulWidget {
  const ShadeGeneratorPage({super.key});

  @override
  State<ShadeGeneratorPage> createState() => _ShadeGeneratorPageState();
}

class _ShadeGeneratorPageState extends State<ShadeGeneratorPage> {
  final TextEditingController _hexController = TextEditingController();
  final List<Map<String, dynamic>> _quickPresets = [
    {'name': 'Indigo Core', 'color': const Color(0xFF6366F1)},
    {'name': 'Electric Violet', 'color': const Color(0xFF8B5CF6)},
    {'name': 'Emerald Forest', 'color': const Color(0xFF10B981)},
    {'name': 'Skyline Blue', 'color': const Color(0xFF0EA5E9)},
    {'name': 'Crimson Rose', 'color': const Color(0xFFF43F5E)},
    {'name': 'Solar Sunset', 'color': const Color(0xFFF97316)},
    {'name': 'Warm Amber', 'color': const Color(0xFFF59E0B)},
    {'name': 'Obsidian Slate', 'color': const Color(0xFF475569)},
  ];

  @override
  void initState() {
    super.initState();
    final storage = context.read<PaletteStorage>();
    _hexController.text = ShadeEngine.toHex(storage.baseColor);
  }

  void _onHexSubmitted(String val) {
    final parsed = ShadeEngine.parseHex(val);
    if (parsed != null) {
      context.read<PaletteStorage>().setBaseColor(parsed, name: 'Custom Ramp');
    }
  }

  void _showSaveDialog(BuildContext context) {
    final storage = context.read<PaletteStorage>();
    final nameController = TextEditingController(text: storage.rampName);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save Color Ramp'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Palette Name',
            hintText: 'e.g. Neon Cyberpunk',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              storage.saveCurrentRamp(nameController.text);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Saved "${nameController.text.trim()}" to collection')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<PaletteStorage>();
    final shades = storage.currentShades;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.palette_rounded, color: Color(0xFF6366F1)),
            SizedBox(width: 8),
            Text('10-Step Ramp Studio'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _showSaveDialog(context),
            icon: const Icon(Icons.bookmark_add_rounded),
            tooltip: 'Save Ramp',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Base Color Selector Card
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
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: storage.baseColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: storage.baseColor.withValues(alpha: 0.4),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            storage.rampName,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            ShadeEngine.toHex(storage.baseColor),
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      child: TextField(
                        controller: _hexController,
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                        decoration: InputDecoration(
                          hintText: '#HEX',
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onSubmitted: _onHexSubmitted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'PRESET ANCHORS',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _quickPresets.map((item) {
                    final isCurrent = (item['color'] as Color).toARGB32() == storage.baseColor.toARGB32();
                    return ActionChip(
                      avatar: CircleAvatar(backgroundColor: item['color'] as Color, radius: 8),
                      label: Text(item['name'] as String),
                      backgroundColor: isCurrent
                          ? (item['color'] as Color).withValues(alpha: 0.15)
                          : null,
                      side: BorderSide(
                        color: isCurrent ? (item['color'] as Color) : Colors.transparent,
                      ),
                      onPressed: () {
                        _hexController.text = ShadeEngine.toHex(item['color'] as Color);
                        storage.setBaseColor(item['color'] as Color, name: item['name'] as String);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Continuous Ramp Bar Preview
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 38,
              child: Row(
                children: shades.map((s) {
                  return Expanded(
                    child: Container(
                      color: s.color,
                      alignment: Alignment.center,
                      child: Text(
                        '${s.step}',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: s.step >= 500 ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'GENERATED TONAL SHADES & CONTRAST',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
          const SizedBox(height: 10),

          // 10 Swatches list
          ...shades.map((shade) => _buildShadeTile(context, shade)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildShadeTile(BuildContext context, ColorShade shade) {
    final whiteContrast = shade.contrastWithWhite.toStringAsFixed(1);
    final blackContrast = shade.contrastWithBlack.toStringAsFixed(1);
    final isWhiteAccessible = shade.contrastWithWhite >= 4.5;
    final isBlackAccessible = shade.contrastWithBlack >= 4.5;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: shade.color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black12),
            ),
            alignment: Alignment.center,
            child: Text(
              '${shade.step}',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 11,
                color: shade.step >= 500 ? Colors.white : Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shade.hexCode,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    _buildWcagBadge('W: $whiteContrast:1', isWhiteAccessible),
                    const SizedBox(width: 6),
                    _buildWcagBadge('B: $blackContrast:1', isBlackAccessible),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy_rounded, size: 18),
            tooltip: 'Copy Hex',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: shade.hexCode));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Copied ${shade.hexCode} to clipboard'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWcagBadge(String text, bool pass) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: pass ? Colors.green.withValues(alpha: 0.12) : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: pass ? Colors.green[700] : Colors.grey[600],
        ),
      ),
    );
  }
}
