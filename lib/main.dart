import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/provider/preference_settings_provider.dart';
import 'screens/main_screen.dart';
// Added import
import 'utils/provider/bookmarks_provider.dart'; // Import BookmarksProvider

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PreferenceSettingsProvider>(
      builder: (context, prefSetProvider, _) {
        return MaterialApp(
          title: 'Quran App',
          theme: ThemeData(
            primaryColor: const Color(0xFF091945),
            scaffoldBackgroundColor: Colors.white,
            fontFamily: 'Roboto',
            textTheme: const TextTheme(
              titleLarge: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              bodyMedium: TextStyle(
                fontSize: 16.0,
                color: Colors.black,
              ),
            ),
            iconTheme: const IconThemeData(color: Colors.black),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: const Color(0xFF091945),
            scaffoldBackgroundColor:
                const Color(0xFF091945), // Updated to desired color
            fontFamily: 'Roboto',
            textTheme: const TextTheme(
              titleLarge: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              bodyMedium: TextStyle(
                fontSize: 16.0,
                color: Colors.white,
              ),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          themeMode:
              prefSetProvider.isDarkTheme ? ThemeMode.dark : ThemeMode.light,
          home: const MainScreen(),
          // navigatorObservers: [routeObserver],
        );
      },
    );
  }
}

// route_observer.dart is imported from utils/route_observer/route_observer.dart