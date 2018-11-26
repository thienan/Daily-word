import './../../models/word.dart';
import './../../models/language.dart';
import 'api_bloc_utils.dart';
import 'package:html/parser.dart';
import 'package:html/dom.dart';
import './../words_storage_bloc.dart';
import 'package:async/async.dart';

class ApiRomanianBloc extends ApiBlocUtils {
  ApiRomanianBloc()
      : super(
          language: 'Romanian',
          getDefinitionUrl: "https://ro.wiktionary.org/wiki/{1}?printable=yes",
          getDailyWordUrl: "",
        );

  Future<void> searchForWords(String _word) async {
    searchForSingleWord(_word);
  }

  @override
  Word buildWord(String _word, String _responseBody) {
    bool _defIsRomanian = false;
    String _defType = '';
    Word _rez = Word(
      name: _word,
      definitions: {},
      language: languages[language],
      isFavorite: false,
    );

    final _html = parse(_responseBody);
    final _content = _html.getElementsByClassName("mw-parser-output");
    if (_content.length == 0) return null;
    List<Element> _children = _content[0].children;

    for (Element _element in _children) {
      if (_element.outerHtml.startsWith("<h2")) {
        if (_element.children != null)
          _defIsRomanian = (_element.children.first.id == "rom.C3.A2n.C4.83");
      }
      if (_defIsRomanian == false) continue;
      if (_element.outerHtml.startsWith("<h3")) {
        _defType = _element.text;
      }
      if (_element.outerHtml.startsWith("<ol")) {
        for (Element _definition in _element.children) {
          // process the definitions
          if (_rez.definitions[_defType] == null)
            _rez.definitions[_defType] = [];
          _rez.definitions[_defType].add(_definition.text);
        }
      }
    }

    if (_rez.definitions.isEmpty) return null;

    WordsStorageBloc().addNewDailyWord(_rez);
    return _rez;
  }
}
