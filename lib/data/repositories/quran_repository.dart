import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/cached_surah.dart';
import '../models/cached_prayer_times.dart';
import '../models/cached_audio.dart';

class QuranRepository {
  final Dio _dio;
  late Box<CachedSurah> _surahBox;
  late Box<CachedPrayerTimes> _prayerTimesBox;
  late Box<CachedAudioFile> _audioBox;
  final Connectivity _connectivity;

  QuranRepository(this._dio) : _connectivity = Connectivity();

  // Initialize Hive boxes
  Future<void> initialize() async {
    _surahBox = await Hive.openBox<CachedSurah>('surahs');
    _prayerTimesBox = await Hive.openBox<CachedPrayerTimes>('prayer_times');
    _audioBox = await Hive.openBox<CachedAudioFile>('audio_files');
  }

  // Check internet connectivity
  Future<bool> get hasInternetConnection async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Get all Surahs with caching
  Future<List<Map<String, dynamic>>> getSurahs() async {
    // Check cache first
    final cached = _surahBox.values.toList();
    if (cached.isNotEmpty && !cached.first.isExpired) {
      return cached
          .map((surah) => {
                'number': surah.number,
                'name': surah.name,
                'englishName': surah.englishName,
                'revelationType': surah.revelationType,
                'numberOfAyahs': surah.numberOfAyahs,
              })
          .toList();
    }

    // If no internet, return cached data even if expired
    if (!await hasInternetConnection) {
      if (cached.isNotEmpty) {
        return cached
            .map((surah) => {
                  'number': surah.number,
                  'name': surah.name,
                  'englishName': surah.englishName,
                  'revelationType': surah.revelationType,
                  'numberOfAyahs': surah.numberOfAyahs,
                })
            .toList();
      }
      throw Exception('No internet connection and no cached data available');
    }

    try {
      // Fetch from API
      final response =
          await _dio.get('http://api.alquran.cloud/v1/quran/quran-uthmani');

      if (response.statusCode == 200 && response.data['status'] == 'OK') {
        final List<dynamic> surahs = response.data['data']['surahs'];

        // Clear old cache
        await _surahBox.clear();

        // Cache new data
        for (var surah in surahs) {
          final cachedSurah = CachedSurah.fromJson(surah);
          await _surahBox.put(surah['number'], cachedSurah);
        }

        return surahs.cast<Map<String, dynamic>>();
      }

      throw Exception('Failed to load surahs from API');
    } catch (e) {
      // If API fails, return cached data
      if (cached.isNotEmpty) {
        return cached
            .map((surah) => {
                  'number': surah.number,
                  'name': surah.name,
                  'englishName': surah.englishName,
                  'revelationType': surah.revelationType,
                  'numberOfAyahs': surah.numberOfAyahs,
                })
            .toList();
      }
      rethrow;
    }
  }

  // Get specific Surah with caching
  Future<Map<String, dynamic>> getSurah(int surahNumber) async {
    // Check cache first
    final cached = _surahBox.get(surahNumber);
    if (cached != null && !cached.isExpired) {
      return {
        'number': cached.number,
        'name': cached.name,
        'englishName': cached.englishName,
        'revelationType': cached.revelationType,
        'numberOfAyahs': cached.numberOfAyahs,
        'ayahs': cached.ayahs
            .map((ayah) => {
                  'number': ayah.number,
                  'text': ayah.text,
                  'numberInSurah': ayah.numberInSurah,
                })
            .toList(),
      };
    }

    // If no internet, return cached data even if expired
    if (!await hasInternetConnection) {
      if (cached != null) {
        return {
          'number': cached.number,
          'name': cached.name,
          'englishName': cached.englishName,
          'revelationType': cached.revelationType,
          'numberOfAyahs': cached.numberOfAyahs,
          'ayahs': cached.ayahs
              .map((ayah) => {
                    'number': ayah.number,
                    'text': ayah.text,
                    'numberInSurah': ayah.numberInSurah,
                  })
              .toList(),
        };
      }
      throw Exception('No internet connection and no cached data available');
    }

    try {
      // Fetch from API
      final response = await _dio
          .get('http://api.alquran.cloud/v1/surah/$surahNumber/quran-uthmani');

      if (response.statusCode == 200 && response.data['status'] == 'OK') {
        final surahData = response.data['data'];

        // Cache the data
        final cachedSurah = CachedSurah.fromJson(surahData);
        await _surahBox.put(surahNumber, cachedSurah);

        return surahData;
      }

      throw Exception('Failed to load surah from API');
    } catch (e) {
      // If API fails, return cached data
      if (cached != null) {
        return {
          'number': cached.number,
          'name': cached.name,
          'englishName': cached.englishName,
          'revelationType': cached.revelationType,
          'numberOfAyahs': cached.numberOfAyahs,
          'ayahs': cached.ayahs
              .map((ayah) => {
                    'number': ayah.number,
                    'text': ayah.text,
                    'numberInSurah': ayah.numberInSurah,
                  })
              .toList(),
        };
      }
      rethrow;
    }
  }

  // Get Prayer Times with caching
  Future<Map<String, dynamic>> getPrayerTimes(double latitude, double longitude,
      {DateTime? date}) async {
    final targetDate = date ?? DateTime.now();

    // Check cache first
    final cached = _prayerTimesBox.values
        .where((pt) => pt.isForLocation(latitude, longitude) && !pt.isExpired)
        .firstOrNull;

    if (cached != null) {
      return cached.toTimingsMap();
    }

    // If no internet, return cached data even if expired
    if (!await hasInternetConnection) {
      final expiredCached = _prayerTimesBox.values
          .where((pt) => pt.isForLocation(latitude, longitude))
          .firstOrNull;

      if (expiredCached != null) {
        return expiredCached.toTimingsMap();
      }
      throw Exception(
          'No internet connection and no cached prayer times available');
    }

    try {
      String dateString = '';
      if (date != null) {
        dateString = '&date=${date.day}-${date.month}-${date.year}';
      }

      final url =
          'https://api.aladhan.com/v1/timings?latitude=$latitude&longitude=$longitude$dateString';
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        final timings = response.data['data']['timings'];

        // Cache the data
        final cachedPrayerTimes = CachedPrayerTimes.fromJson(
          timings,
          targetDate,
          latitude,
          longitude,
        );

        await _prayerTimesBox.add(cachedPrayerTimes);

        return timings;
      }

      throw Exception('Failed to load prayer times from API');
    } catch (e) {
      // If API fails, return any cached data
      final expiredCached = _prayerTimesBox.values
          .where((pt) => pt.isForLocation(latitude, longitude))
          .firstOrNull;

      if (expiredCached != null) {
        return expiredCached.toTimingsMap();
      }
      rethrow;
    }
  }

  // Download and cache audio file
  Future<String?> downloadAudioFile(int surahNumber, int ayahNumber) async {
    final fileName =
        '${surahNumber.toString().padLeft(3, '0')}${ayahNumber.toString().padLeft(3, '0')}.mp3';

    // Check if already cached
    final cached = _audioBox.values
        .where((audio) =>
            audio.surahNumber == surahNumber &&
            audio.ayahNumber == ayahNumber &&
            !audio.isExpired)
        .firstOrNull;

    if (cached != null && File(cached.localPath).existsSync()) {
      return cached.localPath;
    }

    if (!await hasInternetConnection) {
      // Return cached file even if expired if no internet
      final expiredCached = _audioBox.values
          .where((audio) =>
              audio.surahNumber == surahNumber &&
              audio.ayahNumber == ayahNumber)
          .firstOrNull;

      if (expiredCached != null && File(expiredCached.localPath).existsSync()) {
        return expiredCached.localPath;
      }
      return null;
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final audioDir = Directory('${directory.path}/audio');
      if (!audioDir.existsSync()) {
        audioDir.createSync(recursive: true);
      }

      final localPath = '${audioDir.path}/$fileName';
      final url =
          'https://everyayah.com/data/AbdulSamad_64kbps_QuranExplorer.Com/$fileName';

      final response = await _dio.download(url, localPath);

      if (response.statusCode == 200) {
        final file = File(localPath);
        final fileSize = await file.length();

        // Cache metadata
        final cachedAudio = CachedAudioFile(
          surahNumber: surahNumber,
          ayahNumber: ayahNumber,
          localPath: localPath,
          originalUrl: url,
          fileSize: fileSize,
          downloadedAt: DateTime.now(),
        );

        await _audioBox.add(cachedAudio);

        return localPath;
      }

      return null;
    } catch (e) {
      // Return cached file if download fails
      final expiredCached = _audioBox.values
          .where((audio) =>
              audio.surahNumber == surahNumber &&
              audio.ayahNumber == ayahNumber)
          .firstOrNull;

      if (expiredCached != null && File(expiredCached.localPath).existsSync()) {
        return expiredCached.localPath;
      }
      return null;
    }
  }

  // Get translations with caching
  Future<List<Map<String, dynamic>>> getTranslations(
      int surahNumber, List<String> editions) async {
    // For now, we'll implement basic API call
    // In a full implementation, you'd cache translations too
    if (!await hasInternetConnection) {
      throw Exception('No internet connection - translations not cached yet');
    }

    try {
      final editionsParam = editions.join(',');
      final url =
          'http://api.alquran.cloud/v1/surah/$surahNumber/editions/$editionsParam';

      final response = await _dio.get(url);

      if (response.statusCode == 200 && response.data['status'] == 'OK') {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }

      throw Exception('Failed to load translations');
    } catch (e) {
      rethrow;
    }
  }

  // Get tafsir with caching
  Future<Map<String, dynamic>> getTafsir(
      int surahNumber, String edition) async {
    // For now, we'll implement basic API call
    // In a full implementation, you'd cache tafsir too
    if (!await hasInternetConnection) {
      throw Exception('No internet connection - tafsir not cached yet');
    }

    try {
      final url = 'http://api.alquran.cloud/v1/surah/$surahNumber/$edition';

      final response = await _dio.get(url);

      if (response.statusCode == 200 && response.data['status'] == 'OK') {
        return response.data['data'];
      }

      throw Exception('Failed to load tafsir');
    } catch (e) {
      rethrow;
    }
  }

  // Clear all cache
  Future<void> clearCache() async {
    await _surahBox.clear();
    await _prayerTimesBox.clear();
    await _audioBox.clear();

    // Also delete audio files
    final directory = await getApplicationDocumentsDirectory();
    final audioDir = Directory('${directory.path}/audio');
    if (audioDir.existsSync()) {
      audioDir.deleteSync(recursive: true);
    }
  }

  // Get cache size info
  Future<Map<String, dynamic>> getCacheInfo() async {
    final directory = await getApplicationDocumentsDirectory();
    final audioDir = Directory('${directory.path}/audio');

    int audioFiles = 0;
    int audioSizeBytes = 0;

    if (audioDir.existsSync()) {
      final files = audioDir.listSync();
      audioFiles = files.length;
      for (var file in files) {
        if (file is File) {
          audioSizeBytes += await file.length();
        }
      }
    }

    return {
      'surahs_cached': _surahBox.length,
      'prayer_times_cached': _prayerTimesBox.length,
      'audio_files_cached': audioFiles,
      'audio_cache_size_mb':
          (audioSizeBytes / (1024 * 1024)).toStringAsFixed(2),
      'total_cache_items':
          _surahBox.length + _prayerTimesBox.length + audioFiles,
    };
  }
}
