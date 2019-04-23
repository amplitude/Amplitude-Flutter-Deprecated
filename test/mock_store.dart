import 'package:amplitude_flutter/src/store.dart';
import 'package:amplitude_flutter/src/event.dart';

class MockStore implements Store {
  @override
  int length = 0;

  final List<Event> db = <Event>[];

  @override
  Future<int> add(Event event) {
    db.add(event);
    length++;
    return Future.value(0);
  }

  @override
  Future<void> delete(List<int> eventIds) async {}

  @override
  Future<void> empty() async {
    db.clear();
    length = 0;
  }

  @override
  Future<int> count() async {
    return Future.value(length);
  }

  @override
  Future<List<Event>> fetch(int count) {
    final List<Event> popped = db.sublist(0, count);
    return Future.value(popped);
  }
}
