import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/palette_storage.dart';
import 'pages/export_spec_page.dart';
import 'pages/gradient_mixer_page.dart';
import 'pages/saved_palettes_page.dart';
import 'pages/shade_generator_page.dart';

class FayzoxStudioApp extends StatelessWidget {
  const FayzoxStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PaletteStorage>(
      create: (_) => PaletteStorage(),
      child: MaterialApp(
        title: 'Fayzox Color Studio',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          scaffoldBackgroundColor: const Color(0xFFF8FAFC),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6366F1),
            surface: Colors.white,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFF8FAFC),
            elevation: 0,
            centerTitle: false,
            titleTextStyle: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
            iconTheme: IconThemeData(color: Color(0xFF0F172A)),
          ),
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: Colors.white,
            indicatorColor: const Color(0xFF6366F1).withValues(alpha: 0.15),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(
                  color: Color(0xFF6366F1),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                );
              }
              return const TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
                fontSize: 12,
              );
            }),
          ),
        ),
        home: const _FayzoxStudioHome(),
      ),
    );
  }
}

class _FayzoxStudioHome extends StatefulWidget {
  const _FayzoxStudioHome();

  @override
  State<_FayzoxStudioHome> createState() => _FayzoxStudioHomeState();
}

class _FayzoxStudioHomeState extends State<_FayzoxStudioHome> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    ShadeGeneratorPage(),
    GradientMixerPage(),
    SavedPalettesPage(),
    ExportSpecPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.palette_outlined),
            selectedIcon: Icon(Icons.palette_rounded),
            label: 'Ramp Gen',
          ),
          NavigationDestination(
            icon: Icon(Icons.gradient_outlined),
            selectedIcon: Icon(Icons.gradient_rounded),
            label: 'Gradient',
          ),
          NavigationDestination(
            icon: Icon(Icons.collections_bookmark_outlined),
            selectedIcon: Icon(Icons.collections_bookmark_rounded),
            label: 'Palettes',
          ),
          NavigationDestination(
            icon: Icon(Icons.code_outlined),
            selectedIcon: Icon(Icons.code_rounded),
            label: 'Export Spec',
          ),
        ],
      ),
    );
  }
}
