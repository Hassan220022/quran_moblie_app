import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/provider/preference_settings_provider.dart';
import 'bookmark.dart';
import 'search.dart';
import 'surah_list.dart';
import 'prayer.dart'; // Ensure this import points to your PrayerTimesWidget file
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
    PrayerTimesWidget(), // Your prayer times widget
  ];

  // List of titles corresponding to each screen
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
        ],
      ),
      body: _screens[_selectedIndex], // Displays the selected screen
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
}
