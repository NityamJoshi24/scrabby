import 'package:flutter/services.dart';

class DictionaryService {
  static final DictionaryService _instance = DictionaryService._internal();
  factory DictionaryService() => _instance;
  DictionaryService._internal();

  Set<String>? _words;
  bool get isLoaded => _words != null;

  Future<void> load() async {
    if(_words != null) return;
    final raw = await rootBundle.loadString('assets/twl06.txt');
    _words = raw.split('\n').map((w) => w.trim().toUpperCase()).where((w) => w.isNotEmpty).toSet();
  }

  bool isValidWord(String word) {
    return _words?.contains(word.toUpperCase()) ?? false;
  }
}