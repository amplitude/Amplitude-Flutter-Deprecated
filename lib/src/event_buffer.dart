import 'dart:math';
import 'package:flutter/foundation.dart';

import 'client.dart';
import 'event.dart';
import 'store.dart';
import 'time_utils.dart';

class EventBuffer {
  EventBuffer(this.client, this.store, {this.size = 10});

  @visibleForTesting
  EventBuffer.private(this.client, this.store, {this.size = 10});

  final Client client;
  final int size;

  Store store;

  /// Returns number of events in buffer
  int get length => store.length;

  /// Adds a raw event hash to the buffer
  Future<void> add(Event event) async {
    event.timestamp = TimeUtils().currentTime();
    await store.add(event);

    if (length >= size) {
      await flush();
    }
  }

  /// Flushes all events in buffer
  Future<void> flush() async {
    if (length > 0) {
      final events = await fetch(length);
      final List<Map<String, dynamic>> payload =
          events.map((e) => e.toPayload()).toList();
      await client.post(payload);
      final eventIds = events.map((e) => e.id).toList();
      await store.delete(eventIds);
    } else {
      await Future.value(null);
    }
  }

  @visibleForTesting
  Future<List<Event>> fetch(int count) async {
    assert(count >= 0);

    final endRange = min(count, store.length);
    return await store.fetch(endRange);
  }
}
