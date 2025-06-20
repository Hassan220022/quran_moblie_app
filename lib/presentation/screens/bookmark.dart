import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/bookmarks_provider.dart';
import '../providers/preference_settings_provider.dart';
import 'surah_reader.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({Key? key}) : super(key: key);

  @override
  _BookmarkScreenState createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<BookmarksProvider, PreferenceSettingsProvider>(
        builder: (context, bookmarksProvider, preferenceProvider, child) {
          final bookmarks = bookmarksProvider.bookmarks;
          final isDarkTheme = preferenceProvider.isDarkTheme;

          if (bookmarksProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (bookmarks.isEmpty) {
            return const Center(
              child: Text(
                'No bookmarks added yet.',
                style: TextStyle(fontSize: 16.0),
              ),
            );
          }

          return ListView.builder(
            itemCount: bookmarks.length,
            itemBuilder: (context, index) {
              final bookmark = bookmarks[index];
              return Dismissible(
                key: Key(
                    '${bookmark.verseNumber}-${bookmark.arabicText.hashCode}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                onDismissed: (direction) {
                  bookmarksProvider.removeBookmark(
                    surahNumber: bookmark.surahNumber,
                    verseNumber: bookmark.verseNumber,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bookmark removed'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        isDarkTheme ? Colors.white : const Color(0xFF091945),
                    child: Text(
                      bookmark.verseNumber.toString(),
                      style: TextStyle(
                        color: isDarkTheme ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(bookmark.surahName),
                  subtitle: Text(
                    bookmark.arabicText,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontFamily: 'Quran',
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.bookmark, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SurahReaderScreen(
                                surahNumber: bookmark.surahNumber,
                                surahName: bookmark.surahName,
                                highlightAyah: bookmark.verseNumber,
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          bookmarksProvider.removeBookmark(
                            surahNumber: bookmark.surahNumber,
                            verseNumber: bookmark.verseNumber,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Bookmark removed'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SurahReaderScreen(
                          surahNumber: bookmark.surahNumber,
                          surahName: bookmark.surahName,
                          highlightAyah: bookmark.verseNumber,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
