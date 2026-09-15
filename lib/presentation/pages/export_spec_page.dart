import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../data/palette_storage.dart';
import '../../domain/shade_engine.dart';

class ExportSpecPage extends StatefulWidget {
  const ExportSpecPage({super.key});

  @override
  State<ExportSpecPage> createState() => _ExportSpecPageState();
}

class _ExportSpecPageState extends State<ExportSpecPage> {
  int _selectedFormat = 0;
  final List<String> _formats = ['Flutter', 'CSS Variables', 'SVG Swatches', 'Tailwind'];

  String _generateExportCode(PaletteStorage storage) {
    final shades = storage.currentShades;
    final rampName = storage.rampName;

    switch (_selectedFormat) {
      case 0:
        return ShadeEngine.exportFlutterCode(rampName, shades);
      case 1:
        return ShadeEngine.exportCssVariables(rampName, shades);
      case 2:
        return ShadeEngine.exportSvg(rampName, shades);
      case 3:
        final prefix = rampName.toLowerCase().replaceAll(RegExp(r'\s+'), '-');
        final map = <String, String>{};
        for (final s in shades) {
          map['${s.step}'] = s.hexCode;
        }
        final wrapper = {prefix: map};
        const encoder = JsonEncoder.withIndent('  ');
        return '// tailwind.config.js\nmodule.exports = {\n  theme: {\n    extend: {\n      colors: ${encoder.convert(wrapper)}\n    }\n  }\n};';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<PaletteStorage>();
    final code = _generateExportCode(storage);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.code_rounded, color: Color(0xFF6366F1)),
            SizedBox(width: 8),
            Text('Export Spec'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_all_rounded),
            tooltip: 'Copy to Clipboard',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Copied ${_formats[_selectedFormat]} specifications!'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active Palette Info Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  CircleAvatar(backgroundColor: storage.baseColor, radius: 10),
                  const SizedBox(width: 10),
                  Text(
                    'Exporting: ${storage.rampName}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const Spacer(),
                  Text(
                    '${storage.currentShades.length} Tokens',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Format Selection Segment
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_formats.length, (idx) {
                  final isSelected = _selectedFormat == idx;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_formats[idx]),
                      selected: isSelected,
                      selectedColor: const Color(0xFF6366F1),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : null,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (_) => setState(() => _selectedFormat = idx),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 14),

            // Code Output View
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A), // Dark slate editor theme
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF1E293B)),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    code,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      height: 1.5,
                      color: Color(0xFFE2E8F0),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Full Copy Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: code));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Copied ${_formats[_selectedFormat]} code to clipboard!'),
                    ),
                  );
                },
                icon: const Icon(Icons.copy_rounded),
                label: Text('COPY ${_formats[_selectedFormat].toUpperCase()} SPEC'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
