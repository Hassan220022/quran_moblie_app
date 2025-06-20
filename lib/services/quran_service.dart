import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/translation.dart';
import '../models/tafsir.dart';
import '../repositories/quran_repository.dart';

class QuranService {
  static const String baseUrl = 'http://api.alquran.cloud/v1';
  final QuranRepository? _repository;

  QuranService({QuranRepository? repository}) : _repository = repository;

  Future<TranslationSet> getTranslations(
      int surahNumber, List<String> editions) async {
    try {
      final editionsParam = editions.join(',');
      final url = '$baseUrl/surah/$surahNumber/editions/$editionsParam';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          List<Translation> translations = [];

          // Handle multiple editions
          if (data['data'] is List) {
            for (var editionData in data['data']) {
              if (editionData['ayahs'] != null) {
                for (var ayah in editionData['ayahs']) {
                  translations.add(Translation.fromJson(
                      {...ayah, 'edition': editionData['edition']}));
                }
              }
            }
          }

          return TranslationSet(
            translations: translations,
            surahName: data['data'][0]['englishName'] ?? '',
            surahNumber: surahNumber,
          );
        }
      }

      throw Exception('Failed to load translations');
    } catch (e) {
      throw Exception('Error fetching translations: $e');
    }
  }

  Future<TafsirSet> getTafsir(int surahNumber, String edition) async {
    try {
      final url = '$baseUrl/surah/$surahNumber/$edition';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          List<Tafsir> tafasir = [];

          if (data['data']['ayahs'] != null) {
            for (var ayah in data['data']['ayahs']) {
              tafasir.add(Tafsir.fromJson({
                'ayahNumber': ayah['numberInSurah'],
                'text': ayah['text'],
                'edition': data['data']['edition']
              }));
            }
          }

          return TafsirSet(
            tafasir: tafasir,
            surahName: data['data']['englishName'] ?? '',
            surahNumber: surahNumber,
          );
        }
      }

      throw Exception('Failed to load tafsir');
    } catch (e) {
      throw Exception('Error fetching tafsir: $e');
    }
  }

  Future<Map<String, dynamic>> getSurahInfo(int surahNumber) async {
    try {
      final url = '$baseUrl/surah/$surahNumber';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          return {
            'name': data['data']['name'],
            'englishName': data['data']['englishName'],
            'numberOfAyahs': data['data']['numberOfAyahs'],
            'revelationType': data['data']['revelationType'],
          };
        }
      }

      throw Exception('Failed to load surah info');
    } catch (e) {
      throw Exception('Error fetching surah info: $e');
    }
  }

  // Repository-enhanced methods
  Future<List<Map<String, dynamic>>> getSurahs() async {
    if (_repository != null) {
      return await _repository!.getSurahs();
    }

    // Fallback to direct API call
    return await getSurahsFromAPI();
  }

  Future<Map<String, dynamic>> getSurah(int surahNumber) async {
    if (_repository != null) {
      return await _repository!.getSurah(surahNumber);
    }

    // Fallback to direct API call
    return await getSurahFromAPI(surahNumber);
  }

  // Download audio file (cached if repository available)
  Future<String?> downloadAudioFile(int surahNumber, int ayahNumber) async {
    if (_repository != null) {
      return await _repository!.downloadAudioFile(surahNumber, ayahNumber);
    }

    // Return null if no repository (no caching available)
    return null;
  }

  // Static methods for direct API access (backward compatibility)
  static Future<List<Map<String, dynamic>>> getSurahsFromAPI() async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/quran/quran-uthmani'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return List<Map<String, dynamic>>.from(data['data']['surahs']);
        }
      }
      throw Exception('Failed to load surahs');
    } catch (e) {
      throw Exception('Error fetching surahs: $e');
    }
  }

  static Future<Map<String, dynamic>> getSurahFromAPI(int surahNumber) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/surah/$surahNumber/quran-uthmani'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return data['data'];
        }
      }
      throw Exception('Failed to load surah');
    } catch (e) {
      throw Exception('Error fetching surah: $e');
    }
  }
}
