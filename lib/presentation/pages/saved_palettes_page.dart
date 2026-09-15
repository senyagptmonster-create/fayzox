import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/palette_storage.dart';
import '../../domain/shade_engine.dart';

class SavedPalettesPage extends StatelessWidget {
  const SavedPalettesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<PaletteStorage>();
    final saved = storage.savedRamps;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.collections_bookmark_rounded, color: Color(0xFF6366F1)),
            SizedBox(width: 8),
            Text('Saved Palettes'),
          ],
        ),
      ),
      body: saved.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.palette_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No saved palettes yet',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Generate a ramp and tap the bookmark icon to save here.',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: saved.length,
              itemBuilder: (context, index) {
                final ramp = saved[index];
                final isCurrentlyActive = storage.baseColor.toARGB32() == ramp.baseColor.toARGB32() &&
                    storage.rampName == ramp.name;

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isCurrentlyActive
                          ? const Color(0xFF6366F1)
                          : Theme.of(context).dividerColor.withValues(alpha: 0.15),
                      width: isCurrentlyActive ? 1.5 : 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: ramp.baseColor,
                            radius: 12,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ramp.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  ShadeEngine.toHex(ramp.baseColor),
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isCurrentlyActive)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'ACTIVE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6366F1),
                                ),
                              ),
                            ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.grey, size: 20),
                            onPressed: () {
                              storage.deleteRamp(ramp.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Removed "${ramp.name}"')),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Swatch row
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          height: 28,
                          child: Row(
                            children: ramp.shades.map((s) {
                              return Expanded(
                                child: Container(color: s.color),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              storage.loadRampIntoActive(ramp);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Loaded "${ramp.name}" into Studio')),
                              );
                            },
                            icon: const Icon(Icons.tune_rounded, size: 16),
                            label: const Text('Open in Studio'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
