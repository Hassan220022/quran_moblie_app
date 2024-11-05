// lib/services/audio_player_service.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart'; // If you intend to use ChangeNotifier

class AudioPlayerService with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  AudioPlayerService() {
    _audioPlayer.onPlayerComplete.listen((event) {
      _isPlaying = false;
      notifyListeners();
    });

    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      _isPlaying = state == PlayerState.playing;
      notifyListeners();
    });
  }

  Future<void> play(String url) async {
    try {
      await _audioPlayer.play(UrlSource(url));
      _isPlaying = true;
      notifyListeners();
    } catch (e) {
      // Handle play failure
      _isPlaying = false;
      notifyListeners();
    }
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    _isPlaying = false;
    notifyListeners();
  }

  bool get isPlaying => _isPlaying;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
