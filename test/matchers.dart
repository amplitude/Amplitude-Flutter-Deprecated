import 'package:flutter_test/flutter_test.dart';

class ContainsSubMap extends Matcher {
  ContainsSubMap(this._expectedMap) {
    _matcherMap = _expectedMap
        .map<String, Matcher>((k, dynamic v) => MapEntry(k, equals(v)));
  }

  Map<String, Matcher> _matcherMap;
  Map<String, dynamic> _expectedMap;

  @override
  bool matches(dynamic actual, Map<dynamic, dynamic> matchState) {
    return _matcherMap.entries
        .map((entry) => entry.value.matches(actual[entry.key], matchState))
        .reduce((acc, success) => acc && success);
  }

  @override
  Description describe(Description description) =>
      description.add('matches sub-map ${_expectedMap.toString()}');
}
