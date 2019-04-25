import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

import 'client.dart';
import 'config.dart';
import 'event.dart';
import 'service_provider.dart';
import 'store.dart';
import 'time_utils.dart';

class EventBuffer {
  EventBuffer(this.provider, this.config) {
    client = provider.client;
    store = provider.store;
    flushInProgress = false;

    Timer.periodic(
        Duration(seconds: config.flushPeriod), (Timer _t) => flush());
  }

  final Config config;
  final ServiceProvider provider;
  Client client;
  Store store;
  bool flushInProgress;

  /// Returns number of events in buffer
  int get length => store.length;

  /// Adds a raw event hash to the buffer
  Future<void> add(Event event) async {
    event.timestamp = TimeUtils().currentTime();
    await store.add(event);

    if (length >= config.bufferSize) {
      await flush();
    }
  }

  /// Flushes all events in buffer
  Future<void> flush() async {
    if (length < 1 || flushInProgress) {
      return;
    }

    flushInProgress = true;
    final events = await fetch(length);
    final List<Map<String, dynamic>> payload =
        events.map((e) => e.toPayload()).toList();

    final success = await client.post(payload);
    if (success) {
      final eventIds = events.map((e) => e.id).toList();
      await store.delete(eventIds);
    }
    flushInProgress = false;
  }

  @visibleForTesting
  Future<List<Event>> fetch(int count) async {
    assert(count >= 0);

    final endRange = min(count, store.length);
    return await store.fetch(endRange);
  }
}
