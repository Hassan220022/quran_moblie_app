import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/preference_settings_provider.dart';
import '../providers/enhanced_theme_provider.dart';
import 'bookmark.dart';
import 'search.dart';
import 'surah_list.dart';
import 'prayer.dart';
import 'simple_cache_management.dart';
import 'settings_screen.dart';
import 'qibla_screen.dart';
import 'islamic_calendar_screen.dart';
import 'community_screen.dart';
import '../../services/auto_cache_service.dart';
import '../../core/utils/route_observer.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with RouteAware {
  int _selectedIndex = 0;

  // List of screens for navigation
  final List<Widget> _screens = [
    const SurahListScreen(),
    const BookmarkScreen(),
    const SearchScreen(),
    const PrayerTimesWidget(),
    const SettingsScreen(), // Add settings as 5th tab
  ];

  final List<String> _titles = [
    'Surahs',
    'Bookmarks',
    'Search',
    'Prayers',
    'Settings',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  // Handle bottom navigation item tap
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<PreferenceSettingsProvider, EnhancedThemeProvider>(
      builder: (context, prefProvider, themeProvider, child) {
        final isDarkTheme = themeProvider.isDarkTheme(context);
        final colorScheme = Theme.of(context).colorScheme;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              _titles[_selectedIndex],
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Image.asset(
                isDarkTheme
                    ? 'assets/icon_quran_white.png'
                    : 'assets/icon_quran.png',
                width: 28.0,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isDarkTheme ? Icons.light_mode : Icons.dark_mode,
                  color: colorScheme.onSurface,
                ),
                onPressed: () {
                  final newMode =
                      isDarkTheme ? ThemeMode.light : ThemeMode.dark;
                  themeProvider.setThemeMode(newMode);
                },
              ),
              if (_selectedIndex != 4) // Don't show menu when on settings
                Builder(
                  builder: (context) => IconButton(
                    icon: Icon(
                      Icons.menu,
                      color: colorScheme.onSurface,
                    ),
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                  ),
                ),
            ],
          ),
          body: _screens[_selectedIndex],
          endDrawer: _selectedIndex != 4
              ? _buildDrawer(context, isDarkTheme, colorScheme)
              : null,
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              selectedItemColor: colorScheme.primary,
              unselectedItemColor: colorScheme.onSurfaceVariant,
              backgroundColor: colorScheme.surface,
              currentIndex: _selectedIndex,
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              onTap: _onItemTapped,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.list),
                  label: 'Surahs',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bookmark),
                  label: 'Bookmarks',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.access_time),
                  label: 'Prayers',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawer(
      BuildContext context, bool isDarkTheme, ColorScheme colorScheme) {
    return Drawer(
      backgroundColor: colorScheme.surface,
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.menu_book,
                  color: Colors.white,
                  size: 40,
                ),
                SizedBox(width: 16),
                Text(
                  'Quran App',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // New Features Section
          ListTile(
            leading: Icon(
              Icons.explore,
              color: colorScheme.primary,
            ),
            title: Text(
              'Qibla Direction',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            subtitle: Text(
              'Find direction to Mecca',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QiblaScreen()),
              );
            },
          ),

          ListTile(
            leading: Icon(
              Icons.calendar_today,
              color: colorScheme.primary,
            ),
            title: Text(
              'Islamic Calendar',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            subtitle: Text(
              'Hijri dates & events',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const IslamicCalendarScreen()),
              );
            },
          ),

          ListTile(
            leading: Icon(
              Icons.people,
              color: colorScheme.primary,
            ),
            title: Text(
              'Community',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            subtitle: Text(
              'Share & track progress',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CommunityScreen()),
              );
            },
          ),

          const Divider(),

          FutureBuilder<Map<String, dynamic>>(
            future: AutoCacheService.getCacheInfo(),
            builder: (context, snapshot) {
              final cacheInfo = snapshot.data ?? {};
              final cachedSurahs = cacheInfo['cached_surahs'] ?? 0;
              final offlineStatus =
                  cacheInfo['offline_status'] ?? 'No offline content';

              return ListTile(
                leading: Icon(
                  Icons.storage,
                  color: colorScheme.primary,
                ),
                title: Text(
                  'Cache & Offline',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  offlineStatus,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                trailing: cachedSurahs > 0
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$cachedSurahs',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const SimpleCacheManagementScreen()),
                  );
                },
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              Icons.info_outline,
              color: colorScheme.primary,
            ),
            title: Text(
              'About',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              _showAboutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Quran App'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('A beautiful and comprehensive Quran reading app with:'),
            SizedBox(height: 8),
            Text('• Offline reading capabilities'),
            Text('• Audio recitations'),
            Text('• Multiple translations'),
            Text('• Tafsir (commentary)'),
            Text('• Prayer times'),
            Text('• Reading progress tracking'),
            Text('• Bookmarks'),
            Text('• Accessibility features'),
            Text('• Modern theming'),
            SizedBox(height: 8),
            Text('Built with Flutter and powered by Al-Quran Cloud API.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
