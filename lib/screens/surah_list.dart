import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../screens/surah_reader.dart';
import '../utils/provider/preference_settings_provider.dart';
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
    const String apiUrl = 'http://api.alquran.cloud/v1/quran/quran-uthmani';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        List<Surah> fetchedSurahs = [];

        if (data['status'] == 'OK') {
          final List<dynamic> surahs = data['data']['surahs'];
          for (var surah in surahs) {
            fetchedSurahs.add(Surah.fromJson(surah));
          }
        }

        setState(() {
          _surahs = fetchedSurahs;
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
          ? const Center(child: CircularProgressIndicator())
          : _isError
              ? Center(
                  child: Text(
                    'Failed to load surahs. Please try again later.',
                    style: TextStyle(
                      color: isDarkTheme ? Colors.white : Colors.black,
                      fontSize: 16.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  itemCount: _surahs.length,
                  itemBuilder: (context, index) {
                    final surah = _surahs[index];
                    return ListTile(
                      title: Row(
                        children: [
                          Text('${surah.number}. ${surah.name}'),
                          const SizedBox(width: 10), // Add some spacing
                          _buildRevelationIcon(surah.revelationType),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward),
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
                    );
                  },
                ),
    );
  }
}
