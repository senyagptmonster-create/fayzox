import 'package:flutter/material.dart';
import '../app/brand.dart';
import '../app/theme.dart';

class FayzoxMainScreen extends StatefulWidget {
  const FayzoxMainScreen({super.key});
  @override
  State<FayzoxMainScreen> createState() => _FayzoxMainScreenState();
}

class _FayzoxMainScreenState extends State<FayzoxMainScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = const [
    ShadeGeneratorScreen(),
    GradientMixerScreen(),
    SavedPalettesScreen(),
    HexExporterScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Fayzox', style: AppTheme.display(cInk))),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) { setState(() { _currentIndex = index; }); },
        selectedItemColor: cAccent,
        unselectedItemColor: cInk,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.color_lens), label: 'Shades'),
          BottomNavigationBarItem(icon: Icon(Icons.gradient), label: 'Gradients'),
          BottomNavigationBarItem(icon: Icon(Icons.palette), label: 'Palettes'),
          BottomNavigationBarItem(icon: Icon(Icons.import_export), label: 'Export'),
        ],
      ),
    );
  }
}

class ShadeGeneratorScreen extends StatelessWidget {
  const ShadeGeneratorScreen({super.key});
  @override
  Widget build(BuildContext context) { return Center(child: Text('Shade Generator', style: AppTheme.text(cInk))); }
}
class GradientMixerScreen extends StatelessWidget {
  const GradientMixerScreen({super.key});
  @override
  Widget build(BuildContext context) { return Center(child: Text('Gradient Mixer', style: AppTheme.text(cInk))); }
}
class SavedPalettesScreen extends StatelessWidget {
  const SavedPalettesScreen({super.key});
  @override
  Widget build(BuildContext context) { return Center(child: Text('Saved Palettes', style: AppTheme.text(cInk))); }
}
class HexExporterScreen extends StatelessWidget {
  const HexExporterScreen({super.key});
  @override
  Widget build(BuildContext context) { return Center(child: Text('Hex Exporter', style: AppTheme.text(cInk))); }
}
