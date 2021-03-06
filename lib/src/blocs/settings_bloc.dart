import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:rxdart/rxdart.dart';
import './../models/language.dart';

class SettingsBloc {
  BehaviorSubject languagesStreamController;
  SharedPreferences _pref;
  List<String> _selectedLanguages;
  static final SettingsBloc _singleton = SettingsBloc._internal();

  factory SettingsBloc() {
    return _singleton;
  }

  SettingsBloc._internal() {
    _selectedLanguages = [];
    languagesStreamController = BehaviorSubject(seedValue: []);
    _buildSelectedLanguages();
  }

  void dispose() {
    languagesStreamController.close();
  }

  void _buildSelectedLanguages() async {
    _pref = await SharedPreferences.getInstance();
    // enable all languages by default
    _selectedLanguages =
        _pref.getStringList("SelectedLanguages") ?? languages.keys.toList();
    languagesStreamController.add(_selectedLanguages);
  }

  void languageCheck(String languageName, bool value) async {
    if (value)
      _selectedLanguages.add(languageName);
    else {
      if (_selectedLanguages.length == 1) return;
      _selectedLanguages.removeWhere((item) => item == languageName);
    }

    if (_pref != null) {
      await _pref.setStringList("SelectedLanguages", _selectedLanguages);
      languagesStreamController.add(_selectedLanguages);
    }
  }

  Stream get languagesStream => languagesStreamController.asBroadcastStream();

  bool isLanguageSelected(String language) {
    return _selectedLanguages.contains(language);
  }
}
