import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/surah_entity.dart';
import '../providers/surah_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  Surah? _searchedSurah;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Load all surahs for searching
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<SurahProvider>().surahs.isEmpty) {
        context.read<SurahProvider>().loadAllSurahs();
      }
    });
  }

  Future<void> _searchSurah(String query) async {
    setState(() {
      _isLoading = true;
      _searchedSurah = null;
      _errorMessage = null;
    });

    try {
      final surahProvider = context.read<SurahProvider>();
      final allSurahs = surahProvider.surahs;

      if (allSurahs.isEmpty) {
        await surahProvider.loadAllSurahs();
      }

      Surah? foundSurah;

      // Try to parse as number first
      final surahNumber = int.tryParse(query);
      if (surahNumber != null) {
        try {
          foundSurah = allSurahs.firstWhere(
            (surah) => surah.number == surahNumber,
          );
        } catch (e) {
          foundSurah = null;
        }
      } else {
        // Search by English name (case insensitive)
        try {
          foundSurah = allSurahs.firstWhere(
            (surah) => surah.englishName.toLowerCase() == query.toLowerCase(),
          );
        } catch (e) {
          foundSurah = null;
        }
      }

      setState(() {
        if (foundSurah != null) {
          _searchedSurah = foundSurah;
        } else {
          _errorMessage =
              'Surah not found. Try searching by number (1-114) or English name.';
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred while searching.';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Search By English Name or Number',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        labelText: 'Enter Surah Name or Number',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a search query.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _searchSurah(_searchController.text.trim());
                      }
                    },
                    child: const Text('Search'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : _errorMessage != null
                    ? Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      )
                    : _searchedSurah != null
                        ? Expanded(
                            child: Card(
                              elevation: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${_searchedSurah!.number}. ${_searchedSurah!.englishName}',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _searchedSurah!.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF667eea),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _searchedSurah!.englishNameTranslation,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Revelation Type: ${_searchedSurah!.revelationType}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Number of Ayahs: ${_searchedSurah!.numberOfAyahs}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : const Expanded(
                            child: Center(
                              child: Text(
                                'Enter a Surah name or number to search.',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
          ],
        ),
      ),
    );
  }
}
