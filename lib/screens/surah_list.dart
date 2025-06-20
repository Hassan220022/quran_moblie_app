import 'package:flutter/material.dart';
import '../screens/surah_reader.dart';
import '../utils/provider/preference_settings_provider.dart';
import '../widgets/recent_reading_widget.dart';
import '../services/auto_cache_service.dart';
import '../widgets/enhanced_loading.dart';
import 'package:provider/provider.dart';

class Surah {
  final int number;
  final String name;
  final String revelationType;

  Surah(
      {required this.number, required this.name, required this.revelationType});

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'],
      name: json['name'],
      revelationType: json['revelationType'],
    );
  }
}

class SurahListScreen extends StatefulWidget {
  const SurahListScreen({Key? key}) : super(key: key);

  @override
  _SurahListScreenState createState() => _SurahListScreenState();
}

class _SurahListScreenState extends State<SurahListScreen> {
  List<Surah> _surahs = [];
  bool _isLoading = true;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    fetchSurahs();
  }

  Future<void> fetchSurahs() async {
    try {
      // Use AutoCacheService - automatically handles caching
      final surahsData = await AutoCacheService.getSurahs();

      List<Surah> fetchedSurahs = [];
      for (var surahData in surahsData) {
        fetchedSurahs.add(Surah.fromJson(surahData));
      }

      if (mounted) {
        setState(() {
          _surahs = fetchedSurahs;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching surahs: $e');
      if (mounted) {
        setState(() {
          _isError = true;
          _isLoading = false;
        });
      }
    }
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
    bool isDarkTheme =
        Provider.of<PreferenceSettingsProvider>(context).isDarkTheme;

    return Scaffold(
      body: _isLoading
          ? const Center(
              child: EnhancedLoading(
                message: 'Loading Surahs...',
                style: LoadingStyle.quranStyle,
              ),
            )
          : _isError
              ? Center(
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
                        'Pull down to refresh',
                        style: TextStyle(
                          color: isDarkTheme ? Colors.white70 : Colors.grey,
                          fontSize: 14.0,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _refreshSurahs(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refreshSurahs,
                  color: const Color(0xFF667eea),
                  child: Column(
                    children: [
                      // Recent Reading Widget
                      const RecentReadingWidget(),

                      // Surahs List
                      Expanded(
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: _surahs.length,
                          itemBuilder: (context, index) {
                            final surah = _surahs[index];
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
                                  surah.revelationType,
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
                                    color: const Color(0xFF667eea)
                                        .withOpacity(0.1),
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
                ),
    );
  }

  Future<void> _refreshSurahs() async {
    setState(() {
      _isLoading = true;
      _isError = false;
    });
    await fetchSurahs();
  }
}
