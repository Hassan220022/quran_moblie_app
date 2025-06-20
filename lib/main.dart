import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils/provider/preference_settings_provider.dart';
import 'utils/provider/reading_progress_provider.dart';
import 'screens/main_screen.dart';
import 'screens/onboarding_screen.dart';
import 'utils/provider/bookmarks_provider.dart';
import 'services/auto_cache_service.dart';
import 'services/prayer_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize auto-preloading of popular surahs in background
  _initializeCache();

  // Initialize prayer notification service
  _initializeServices();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PreferenceSettingsProvider()),
        ChangeNotifierProvider(create: (_) => BookmarksProvider()),
        ChangeNotifierProvider(create: (_) => ReadingProgressProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

void _initializeCache() {
  // Cache common surahs in background for permanent offline access
  Future.delayed(const Duration(seconds: 2), () {
    AutoCacheService.cacheCommonSurahs();
  });
}

void _initializeServices() {
  // Initialize prayer notifications and daily ayah
  Future.delayed(const Duration(seconds: 3), () async {
    try {
      await PrayerNotificationService.initialize();
      await PrayerNotificationService.scheduleDailyAyahNotification();
    } catch (e) {
      print('Failed to initialize notification services: $e');
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PreferenceSettingsProvider>(
      builder: (context, prefSetProvider, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
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
          home: const AppInitializer(),
        );
      },
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isLoading = true;
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final hasCompletedOnboarding =
        prefs.getBool('onboarding_completed') ?? false;

    await Future.delayed(const Duration(seconds: 1)); // Splash delay

    setState(() {
      _showOnboarding = !hasCompletedOnboarding;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(
                image: AssetImage('assets/icon_quran.png'),
                width: 100,
                height: 100,
              ),
              SizedBox(height: 24),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
              ),
              SizedBox(height: 16),
              Text(
                'Quran App',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF667eea),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _showOnboarding ? const OnboardingScreen() : const MainScreen();
  }
}
