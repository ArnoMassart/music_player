import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import 'song.dart';

class PlayListProvider extends ChangeNotifier {
  // playlist of songs
  final List<Song> _playlist = [
    Song(
        songName: "So sick",
        artistName: "Neyo",
        albumArtImagePath: "assets/images/cover_art.png",
        audioPath: "audio/song.mp3"),
    Song(
        songName: "Acid Rap",
        artistName: "Chance the Rapper",
        albumArtImagePath: "assets/images/cover_art2.png",
        audioPath: "audio/song.mp3"),
    Song(
        songName: "Phoenix",
        artistName: "ASAP Rocky",
        albumArtImagePath: "assets/images/cover_art3.png",
        audioPath: "audio/song.mp3"),
  ];

  int? _currentSongIndex;

  /* 
  
    A U D I O P L A Y E R
  
  */

  // audio player
  final AudioPlayer _audioPlayer = AudioPlayer();

  // durations
  Duration _currentDuration = Duration.zero;
  Duration _totalDuration = Duration.zero;

  // constructor
  PlayListProvider() {
    listenToDuration();
  }

  // initially not playing
  bool _isPlaying = false;
  bool _isShuffled = false;
  bool _repeatSameSong = false;

  // play the song
  void play() async {
    final String path = _playlist[_currentSongIndex!].audioPath;
    await _audioPlayer.stop(); // stop current song
    await _audioPlayer.play(AssetSource(path)); // play the new song
    _isPlaying = true;
    notifyListeners();
  }

  // pause current song
  void pause() async {
    await _audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }

  // resume playing
  void resume() async {
    await _audioPlayer.resume();
    _isPlaying = true;
    notifyListeners();
  }

  // pause or resume
  void pauseOrResume() async {
    if (_isPlaying) {
      pause();
    } else {
      resume();
    }
    notifyListeners();
  }

  // seek to a specific position in the current song
  void seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  // play next song
  void playNextSong() {
    if (_currentSongIndex != null) {
      if (_currentSongIndex! < _playlist.length - 1) {
        // go to the next song if it is not the last song
        currentSongIndex = _currentSongIndex! + 1;
      } else {
        // if it is the last song, loop back to the first song
        currentSongIndex = 0;
      }
    }
  }

  // play previous song
  void playPreviousSong() async {
    // if more than 2 seconds have passed, restart the current song
    if (_currentDuration.inSeconds > 2) {
      seek(Duration.zero);
    } else {
      if (_currentSongIndex != null) {
        if (_currentSongIndex! > 0) {
          currentSongIndex = _currentSongIndex! - 1;
        } else {
          // if it is the first song, loop back to the last song
          currentSongIndex = _playlist.length - 1;
        }
      }
    }
  }

  // listen to duration
  void listenToDuration() {
    // listen for total duration
    _audioPlayer.onDurationChanged.listen((newDuration) {
      _totalDuration = newDuration;
      notifyListeners();
    });

    // listen for current duration
    _audioPlayer.onPositionChanged.listen((newPosition) {
      _currentDuration = newPosition;
      notifyListeners();
    });

    // listen for when song is complete
    _audioPlayer.onPlayerComplete.listen((event) {
      if (!_repeatSameSong) {
        playNextSong();
      } else {
        play();
        notifyListeners();
      }
    });
  }

  // shuffle playlist
  void shuffle() {
    if (!_isShuffled) {
      // Get the current date and time
      DateTime now = DateTime.now();

      // Get the beginning of the year
      DateTime beginningOfYear = DateTime(now.year, 1, 1);

      // Calculate the difference in seconds
      Duration difference = now.difference(beginningOfYear);
      int totalSeconds = difference.inSeconds;

      playlist.shuffle(Random(totalSeconds));
      _isShuffled = true;
    } else {
      _isShuffled = false;
    }
    notifyListeners();
  }

  // allowed to go to next song
  void repeatSameSongPressed() {
    if (_repeatSameSong) {
      _repeatSameSong = false;
    } else {
      _repeatSameSong = true;
    }
    notifyListeners();
  }

  /* 
  
    G E T T E R S
  
  */

  List<Song> get playlist => _playlist;
  int? get currentSongIndex => _currentSongIndex;
  bool get isPlaying => _isPlaying;
  bool get isShuffled => _isShuffled;
  bool get repeatSameSong => _repeatSameSong;
  Duration get currentDuration => _currentDuration;
  Duration get totalDuration => _totalDuration;

  /* 
  
    S E T T E R S

  */

  set currentSongIndex(int? index) {
    // update current song index
    _currentSongIndex = index;

    if (index != null) {
      play();
    }

    // update UI
    notifyListeners();
  }
}
