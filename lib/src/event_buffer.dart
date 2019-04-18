import 'dart:math';
import 'package:flutter/foundation.dart';

import 'client.dart';

class EventBuffer {
  EventBuffer(this.client, {this.size = 10});

  final Client client;
  final int size;

  // Swap this for a durable backing store
  final List<Map<String, dynamic>> store = [];

  /// Returns number of events in buffer
  num get length => store.length;

  /// Adds a raw event hash to the buffer
  void add(Map<String, dynamic> event) {
    event['timestamp'] = DateTime.now().millisecondsSinceEpoch;
    store.add(event);

    if (length >= size) {
      flush();
    }
  }

  /// Flushes all events in buffer
  Future<void> flush() async {
    if (length > 0) {
      await client.post(dequeue(length));
    } else {
      await Future.value(null);
    }
  }

  @visibleForTesting
  List<Map<String, dynamic>> dequeue(int count) {
    assert(count >= 0);

    final endRange = min(count, store.length);
    final List<Map<String, dynamic>> popped = store.sublist(0, endRange);
    store.removeRange(0, endRange);
    return popped;
  }
}
