import 'package:amplitude_flutter/src/event.dart';
import 'package:amplitude_flutter/src/store.dart';

class MockStore implements Store {
  @override
  int length = 0;
  int curId = 10000;

  final List<Event> db = <Event>[];

  @override
  Future<int> add(Event event) {
    event.id = ++curId;
    db.add(event);
    length++;
    return Future.value(0);
  }

  @override
  Future<void> delete(List<int> eventIds) async {
    db.removeWhere((Event event) => eventIds.contains(event.id));
  }

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
