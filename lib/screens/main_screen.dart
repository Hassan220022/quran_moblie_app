import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quaran_mobile_7th_weak/utils/provider/preference_settings_provider.dart';
import 'bookmark.dart';
import 'quran_reader.dart';
import 'search.dart';
import 'surah_list.dart';
import '../utils/route_observer/route_observer.dart'; // Updated import

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with RouteAware {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const SurahListScreen(),
    const BookmarkScreen(),
    const SearchScreen(),
    const QuranReaderScreen(), // Updated to remove surahNumber parameter
  ];

  @override
  void initState() {
    super.initState();
    // Initialize any necessary data or subscriptions here
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
        backgroundColor:
            Theme.of(context).scaffoldBackgroundColor, // Match background color
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              isDarkTheme
                  ? 'assets/icon_quran_white.png'
                  : 'assets/icon_quran.png',
              width: 28.0,
            ),
            const SizedBox(width: 6.0),
            Text(
              'Quran App',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        actions: [
          const SizedBox(width: 8.0),
          IconButton(
            icon: Icon(
              isDarkTheme ? Icons.light_mode : Icons.dark_mode,
              color: isDarkTheme
                  ? Colors.white
                  : const Color(0xFF5E329D), // Corrected color
            ),
            onPressed: () {
              Provider.of<PreferenceSettingsProvider>(context, listen: false)
                  .enableDarkTheme(!isDarkTheme);
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xff682DBD),
        unselectedItemColor: Colors.grey,
        backgroundColor: isDarkTheme ? const Color(0x00091945) : Colors.white,
        currentIndex: _selectedIndex,
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
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.book),
          //   label: 'Quran',
          // ),
        ],
      ),
    );
  }
}
