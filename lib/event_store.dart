import 'dart:math';

class EventStore {
  EventStore();

  // Swap this for a durable backing store
  final List<Map<String, dynamic>> events = [];

  num get length => events.length;

  void add(Map<String, dynamic> event) {
    event['timestamp'] = DateTime.now().millisecondsSinceEpoch;
    events.add(event);
  }

  List<Map<String, dynamic>> pop(int count) {
    assert(count >= 0);

    final endRange = min(count, events.length);
    final List<Map<String, dynamic>> popped = events.sublist(0, endRange);
    events.removeRange(0, endRange);
    return popped;
  }
}
