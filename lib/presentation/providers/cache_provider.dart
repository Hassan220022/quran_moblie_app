import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../data/repositories/quran_repository.dart';

class CacheProvider extends ChangeNotifier {
  QuranRepository? _repository;
  bool _isInitialized = false;
  Map<String, dynamic> _cacheInfo = {};
  bool _isLoading = false;

  QuranRepository? get repository => _repository;
  bool get isInitialized => _isInitialized;
  Map<String, dynamic> get cacheInfo => _cacheInfo;
  bool get isLoading => _isLoading;

  Future<void> initializeRepository() async {
    if (_isInitialized) return;

    try {
      _isLoading = true;
      notifyListeners();

      final dio = Dio();
      _repository = QuranRepository(dio);
      await _repository!.initialize();

      await updateCacheInfo();

      _isInitialized = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception('Failed to initialize cache: $e');
    }
  }

  Future<void> updateCacheInfo() async {
    if (_repository == null) return;

    try {
      _cacheInfo = await _repository!.getCacheInfo();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to update cache info: $e');
    }
  }

  Future<void> clearAllCache() async {
    if (_repository == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      await _repository!.clearCache();
      await updateCacheInfo();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception('Failed to clear cache: $e');
    }
  }

  // Get formatted cache size
  String get formattedCacheSize {
    final sizeStr = _cacheInfo['audio_cache_size_mb'] ?? '0.00';
    return '$sizeStr MB';
  }

  // Get total cached items
  int get totalCachedItems {
    return _cacheInfo['total_cache_items'] ?? 0;
  }

  // Get offline capability status
  String get offlineStatus {
    final surahs = _cacheInfo['surahs_cached'] ?? 0;
    final prayers = _cacheInfo['prayer_times_cached'] ?? 0;

    if (surahs > 0 && prayers > 0) {
      return 'Partially available offline';
    } else if (surahs > 0) {
      return 'Quran text available offline';
    } else {
      return 'No offline content';
    }
  }
}
