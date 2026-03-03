import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/detection/presentation/pages/image_detection_page.dart';
import 'features/audio_detection/presentation/pages/audio_detection_page.dart';
import 'features/history/presentation/pages/history_page.dart';
import 'core/network/network_info.dart';
import 'core/di/injection_container.dart';

/// Home page with bottom navigation
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 0;
  bool _isOnline = true;

  final List<Widget> _pages = const [
    _HomeContent(),
    ImageDetectionPage(),
    AudioDetectionPage(),
    HistoryPage(),
  ];

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  void _checkConnectivity() async {
    final networkInfo = sl<NetworkInfo>();
    _isOnline = await networkInfo.isConnected;
    setState(() {});

    // Listen to connectivity changes
    networkInfo.onConnectivityChanged.listen((isConnected) {
      if (mounted) {
        setState(() {
          _isOnline = isConnected;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          // Offline indicator
          if (!_isOnline)
            Positioned(
              top: MediaQuery.of(context).padding.top,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.orange.shade800,
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_off, size: 16, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Offline Mode',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.camera_alt_outlined),
            selectedIcon: Icon(Icons.camera_alt),
            label: 'Image',
          ),
          NavigationDestination(
            icon: Icon(Icons.mic_outlined),
            selectedIcon: Icon(Icons.mic),
            label: 'Audio',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }
}

/// Home content widget
class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WildSnap Pro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showAboutDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero section
            Card(
              clipBehavior: Clip.antiAlias,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.tertiary,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      bottom: -20,
                      child: Icon(
                        Icons.pets,
                        size: 150,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Identify Wildlife',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Capture images or record sounds\nto identify animals and birds instantly',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Feature cards
            Text(
              'Choose Detection Method',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Image detection card
            _FeatureCard(
              icon: Icons.camera_alt,
              title: 'Image Detection',
              description: 'Take a photo or select from gallery to identify animals and birds',
              color: Colors.blue,
              onTap: () {
                final homeState = context.findAncestorStateOfType<_HomePageState>();
                homeState?.setState(() {
                  homeState._currentIndex = 1;
                });
              },
            ),
            const SizedBox(height: 12),

            // Audio detection card
            _FeatureCard(
              icon: Icons.mic,
              title: 'Bird Sound Detection',
              description: 'Record bird sounds to identify species by their calls',
              color: Colors.green,
              onTap: () {
                final homeState = context.findAncestorStateOfType<_HomePageState>();
                homeState?.setState(() {
                  homeState._currentIndex = 2;
                });
              },
            ),
            const SizedBox(height: 12),

            // History card
            _FeatureCard(
              icon: Icons.history,
              title: 'Detection History',
              description: 'View all your previous detections and share results',
              color: Colors.orange,
              onTap: () {
                final homeState = context.findAncestorStateOfType<_HomePageState>();
                homeState?.setState(() {
                  homeState._currentIndex = 3;
                });
              },
            ),

            const SizedBox(height: 24),

            // Info section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.offline_bolt,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Works Offline',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'All detection features work without internet connection. '
                      'Your data stays on your device.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'WildSnap Pro',
      applicationVersion: '1.0.0',
      applicationIcon: const FlutterLogo(size: 48),
      children: [
        const Text(
          'A production-grade wildlife detection app that identifies '
          'animals and birds from images and bird sounds.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Features:\n'
          '• On-device AI detection\n'
          '• Offline-first architecture\n'
          '• Bird sound recognition\n'
          '• Detection history\n'
          '• Share results',
        ),
      ],
    );
  }
}

/// Feature card widget
class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
