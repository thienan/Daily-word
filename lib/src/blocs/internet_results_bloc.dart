import './../models/word.dart';
import './apis/api_romanian_bloc.dart';
import './apis/api_english_bloc.dart';
import 'dart:async';

import 'package:rxdart/rxdart.dart';

class InternetResultsBloc {
  BehaviorSubject _wordsStream = BehaviorSubject(seedValue: []);
  List<Word> _myAccumulator = [];
  Map<String, dynamic> _apiLanguageBlocHandlers = {};

  InternetResultsBloc() {
    _buildApiBlocHandlers();
    Observable.merge(
      _apiLanguageBlocHandlers.values.map((item) => item.resultsStream),
    ).scan((accumulator, word, i) => _mergeData(word), []).listen((onData) {
      _wordsStream.add(onData);
    });
  }

  void dispose() {
    _wordsStream.close();
  }

  void _buildApiBlocHandlers() {
    _apiLanguageBlocHandlers['Romanian'] = ApiRomanianBloc();
    _apiLanguageBlocHandlers['English'] = ApiEnglishBloc();
  }

  /// Merge the data from different streams into a single array
  dynamic _mergeData(Word word) {
    if (word == null) return _myAccumulator;
    return _myAccumulator..add(word);
  }

  /// Search for a word in each language
  Future<void> searchForWord(String query) async {
    _myAccumulator = [];
    for (var _apiBloc in _apiLanguageBlocHandlers.values) {
      _apiBloc.cancelExistingSearches();
      if (_apiBloc.languageIsSelected == false) continue;
      _apiBloc.searchForWords(query);
    }
  }

  /// It merges the Observables (one for each language) into one BehaviorSubject
  BehaviorSubject get wordsStream => _wordsStream;
}