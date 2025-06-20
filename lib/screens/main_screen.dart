import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/provider/preference_settings_provider.dart';
import 'bookmark.dart';
import 'search.dart';
import 'surah_list.dart';
import 'prayer.dart';
import 'simple_cache_management.dart';
import 'settings_screen.dart';
import '../services/auto_cache_service.dart';
import '../utils/route_observer/route_observer.dart';

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
  ];

  final List<String> _titles = [
    'Surahs',
    'Bookmarks',
    'Search',
    'Prayers',
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
    bool isDarkTheme =
        Provider.of<PreferenceSettingsProvider>(context).isDarkTheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkTheme ? const Color(0x00091945) : Colors.white,
        elevation: 0,
        title: Text(
          _titles[_selectedIndex],
          style: TextStyle(
            color: isDarkTheme ? Colors.white : const Color(0xff682DBD),
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
              color: isDarkTheme ? Colors.white : const Color(0xFF5E329D),
            ),
            onPressed: () {
              Provider.of<PreferenceSettingsProvider>(context, listen: false)
                  .enableDarkTheme(!isDarkTheme);
            },
          ),
          Builder(
            builder: (context) => IconButton(
              icon: Icon(
                Icons.menu,
                color: isDarkTheme ? Colors.white : const Color(0xFF5E329D),
              ),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      endDrawer: _buildDrawer(context, isDarkTheme),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xff682DBD),
        unselectedItemColor: Colors.grey,
        backgroundColor: isDarkTheme ? const Color(0x00091945) : Colors.white,
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
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
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, bool isDarkTheme) {
    return Drawer(
      backgroundColor: isDarkTheme ? const Color(0xFF091945) : Colors.white,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
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
                  color: isDarkTheme ? Colors.white : const Color(0xFF091945),
                ),
                title: Text(
                  'Cache & Offline',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkTheme ? Colors.white : const Color(0xFF091945),
                  ),
                ),
                subtitle: Text(
                  offlineStatus,
                  style: TextStyle(
                    color: isDarkTheme ? Colors.white70 : Colors.grey.shade600,
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
              Icons.settings,
              color: isDarkTheme ? Colors.white : const Color(0xFF091945),
            ),
            title: Text(
              'Settings',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDarkTheme ? Colors.white : const Color(0xFF091945),
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.info_outline,
              color: isDarkTheme ? Colors.white : const Color(0xFF091945),
            ),
            title: Text(
              'About',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDarkTheme ? Colors.white : const Color(0xFF091945),
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
