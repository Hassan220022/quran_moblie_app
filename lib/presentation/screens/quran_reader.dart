import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/preference_settings_provider.dart';

class Ayah {
  final int numberInSurah;
  final String text;

  Ayah({required this.numberInSurah, required this.text});

  factory Ayah.fromJson(Map<String, dynamic> json) {
    return Ayah(
      numberInSurah: json['numberInSurah'],
      text: json['text'],
    );
  }
}

class QuranReaderScreen extends StatefulWidget {
  const QuranReaderScreen({Key? key}) : super(key: key);

  @override
  _QuranReaderScreenState createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends State<QuranReaderScreen> {
  List<Ayah> _ayahs = [];
  bool _isLoading = true;
  bool _isError = false;

  // Define the Basmallah text to filter out
  static const String basmallahText = "بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ";

  @override
  void initState() {
    super.initState();
    fetchAyahs();
  }

  Future<void> fetchAyahs() async {
    const String apiUrl = 'http://api.alquran.cloud/v1/quran/quran-uthmani';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        List<Ayah> fetchedAyahs = [];

        // Navigate through the JSON structure to extract ayahs
        if (data['status'] == 'OK') {
          final List<dynamic> surahs = data['data']['surahs'];
          for (var surah in surahs) {
            final List<dynamic> ayahs = surah['ayahs'];
            for (var ayah in ayahs) {
              final ayahObj = Ayah.fromJson(ayah + 1);
              // Skip ayahs that exactly match the Basmallah text
              if (ayahObj.text.trim() != basmallahText.trim()) {
                fetchedAyahs.add(ayahObj);
              }
            }
          }
        }

        setState(() {
          _ayahs = fetchedAyahs;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkTheme =
        Provider.of<PreferenceSettingsProvider>(context).isDarkTheme;

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isError
              ? Center(
                  child: Text(
                    'Failed to load ayahs. Please try again later.',
                    style: TextStyle(
                      color: isDarkTheme ? Colors.white : Colors.black,
                      fontSize: 16.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : Column(
                  children: [
                    // Basmallah Image at the top
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.asset(
                        'assets/basmallah.png',
                        height: 50.0,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const Divider(),
                    // Expanded ListView to display ayahs starting from 1
                    Expanded(
                      child: ListView.builder(
                        itemCount: _ayahs.length,
                        itemBuilder: (context, index) {
                          final ayah = _ayahs[index];

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isDarkTheme
                                  ? Colors.white
                                  : const Color(0xFF091945),
                              child: Text(
                                ayah.numberInSurah.toString(),
                                style: TextStyle(
                                  color:
                                      isDarkTheme ? Colors.black : Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              ayah.text,
                              style: TextStyle(
                                color:
                                    isDarkTheme ? Colors.white : Colors.black,
                                fontSize: 16.0,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
