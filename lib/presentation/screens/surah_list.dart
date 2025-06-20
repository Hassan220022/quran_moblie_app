import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/preference_settings_provider.dart';
import '../providers/surah_provider.dart';
import '../screens/surah_reader.dart';
import '../widgets/recent_reading_widget.dart';
import '../widgets/enhanced_loading.dart';

class SurahListScreen extends StatefulWidget {
  const SurahListScreen({Key? key}) : super(key: key);

  @override
  _SurahListScreenState createState() => _SurahListScreenState();
}

class _SurahListScreenState extends State<SurahListScreen> {
  @override
  void initState() {
    super.initState();
    // Load surahs using clean architecture provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SurahProvider>().loadAllSurahs();
        });
  }

  Widget _buildRevelationIcon(String type) {
    String assetPath = '';
    if (type.toLowerCase() == 'meccan') {
      assetPath = 'assets/icon/kaaba.png';
    } else if (type.toLowerCase() == 'medinan') {
      assetPath = 'assets/icon/dome.png';
    }
    return Image.asset(
      assetPath,
      width: 24,
      height: 24,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<SurahProvider, PreferenceSettingsProvider>(
        builder: (context, surahProvider, preferenceProvider, child) {
          final isDarkTheme = preferenceProvider.isDarkTheme;

          if (surahProvider.isLoading) {
            return const Center(
              child: EnhancedLoading(
                message: 'Loading Surahs...',
                style: LoadingStyle.quranStyle,
              ),
            );
          }

          if (surahProvider.errorMessage != null) {
            return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: isDarkTheme ? Colors.white70 : Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load surahs',
                        style: TextStyle(
                          color: isDarkTheme ? Colors.white : Colors.black,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                    surahProvider.errorMessage!,
                    textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDarkTheme ? Colors.white70 : Colors.grey,
                          fontSize: 14.0,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                    onPressed: () => surahProvider.refresh(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => surahProvider.refresh(),
                  color: const Color(0xFF667eea),
                  child: Column(
                    children: [
                      // Recent Reading Widget
                      const RecentReadingWidget(),

                      // Surahs List
                      Expanded(
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: surahProvider.surahs.length,
                          itemBuilder: (context, index) {
                      final surah = surahProvider.surahs[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isDarkTheme
                                      ? [
                                          const Color(0xFF2a2a3e),
                                          const Color(0xFF1e1e2e)
                                        ]
                                      : [Colors.white, const Color(0xFFf8f9fa)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDarkTheme
                                        ? Colors.black.withOpacity(0.3)
                                        : Colors.grey.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF667eea),
                                        Color(0xFF764ba2),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${surah.number}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        surah.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: isDarkTheme
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    _buildRevelationIcon(surah.revelationType),
                                  ],
                                ),
                                subtitle: Text(
                            '${surah.revelationType} • ${surah.numberOfAyahs} verses',
                                  style: TextStyle(
                                    color: isDarkTheme
                                        ? Colors.white70
                                        : Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                              color: const Color(0xFF667eea).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Color(0xFF667eea),
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SurahReaderScreen(
                                        surahNumber: surah.number,
                                        surahName: surah.name,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          );
        },
                ),
    );
  }
}
