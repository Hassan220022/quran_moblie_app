import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import '../../data/datasources/quran_remote_datasource.dart';
import '../../data/repositories/quran_repository.dart';
import '../../domain/repositories/quran_repository_interface.dart';
import '../../domain/usecases/get_surah_usecase.dart';
import '../../domain/usecases/manage_bookmarks_usecase.dart';
import '../../presentation/providers/bookmarks_provider.dart';
import '../../presentation/providers/surah_provider.dart';

/// Simple dependency injection container for clean architecture
/// In a larger app, consider using GetIt, Riverpod, or Injectable
class DependencyInjection {
  static late QuranRepositoryInterface _quranRepository;
  static late GetSurahUseCase _getSurahUseCase;
  static late ManageBookmarksUseCase _manageBookmarksUseCase;
  static late BookmarksProvider _bookmarksProvider;
  static late SurahProvider _surahProvider;

  /// Initialize all dependencies
  static Future<void> init() async {
    // External dependencies
    final httpClient = http.Client();
    final connectivity = Connectivity();

    // Data sources
    final remoteDataSource = QuranRemoteDataSource(client: httpClient);

    // Repository
    final repository = QuranRepository(
      remoteDataSource: remoteDataSource,
      connectivity: connectivity,
    );
    await repository.initialize();
    _quranRepository = repository;

    // Use cases
    _getSurahUseCase = GetSurahUseCase(_quranRepository);
    _manageBookmarksUseCase = ManageBookmarksUseCase(_quranRepository);

    // Providers
    _bookmarksProvider = BookmarksProvider(_manageBookmarksUseCase);
    _surahProvider = SurahProvider(_getSurahUseCase);
  }

  /// Get the Quran repository instance
  static QuranRepositoryInterface get quranRepository => _quranRepository;

  /// Get the GetSurahUseCase instance
  static GetSurahUseCase get getSurahUseCase => _getSurahUseCase;

  /// Get the ManageBookmarksUseCase instance
  static ManageBookmarksUseCase get manageBookmarksUseCase =>
      _manageBookmarksUseCase;

  /// Get the BookmarksProvider instance
  static BookmarksProvider get bookmarksProvider => _bookmarksProvider;

  /// Get the SurahProvider instance
  static SurahProvider get surahProvider => _surahProvider;

  /// Factory method to create new providers when needed
  static BookmarksProvider createBookmarksProvider() {
    return BookmarksProvider(_manageBookmarksUseCase);
  }

  /// Factory method to create new surah providers when needed
  static SurahProvider createSurahProvider() {
    return SurahProvider(_getSurahUseCase);
  }

  /// Dispose resources when app closes
  static void dispose() {
    // Clean up resources if needed
  }
}
