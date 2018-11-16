import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import 'word.dart';
import 'language.dart';

class DexOnlineApi {
  DexOnlineApi();

  static Future<Word> getDailyWord() async {
    final response = await http.get('https://dexonline.ro/cuvantul-zilei');
    var document = parse(response.body);
    String _wordName =
        document.getElementsByTagName("meta")[2].attributes["content"];
    _wordName = _wordName.split(": ")[1];

    return Word(
        language: languages['Romanian'],
        name: _wordName,
        definition: await getWordDefinition(_wordName),
        isFavorite: false);
  }

  static Future<String> getWordDefinition(String _word) async {
    Element _definition;
    final response = await http.get('http://dex.ro/${_word}');
    if (response.statusCode != 200) {
      return 'Nu s-a putut afla definitia.';
    }

    _definition = parse(response.body)
        .getElementById('results')
        .getElementsByClassName('res')[0];

    return _parseResponse(_definition.innerHtml);
  }

  static String _parseResponse(String _html) {
    String _rez = '';
    var i, j;
    for (i = 0; i < _html.length; ++i) {
      if (_html[i] == '>' && i < _html.length - 1) {
        for (j = i + 1; j < _html.length && _html[j] != '<'; ++j) {
          _rez += _html[j];
        }
        i = j;
      }
    }
    return _rez;
  }
}
