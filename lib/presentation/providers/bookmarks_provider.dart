import 'package:flutter/material.dart';
import '../../data/models/bookmark.dart';

class BookmarksProvider with ChangeNotifier {
  final List<Bookmark> _bookmarks = [];

  List<Bookmark> get bookmarks => _bookmarks;

  void addBookmark(Bookmark bookmark) {
    _bookmarks.add(bookmark);
    notifyListeners();
  }

  void removeBookmark(int index) {
    if (index >= 0 && index < _bookmarks.length) {
      _bookmarks.removeAt(index);
      notifyListeners();
    }
  }

  bool isBookmarked(Bookmark bookmark) {
    return _bookmarks.any((b) =>
        b.surahNumber == bookmark.surahNumber &&
        b.ayahNumber == bookmark.ayahNumber);
  }
}
