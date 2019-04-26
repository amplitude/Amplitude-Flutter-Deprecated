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
    backoff = false;

    Timer.periodic(
        Duration(seconds: config.flushPeriod), (Timer _t) => flush());
  }

  final Config config;
  final ServiceProvider provider;
  Client client;
  Store store;

  bool flushInProgress;
  bool backoff;
  int numEvents;

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
    numEvents ??= length;
    final events = await fetch(numEvents);
    final List<Map<String, dynamic>> payload =
        events.map((e) => e.toPayload()).toList();

    final status = await client.post(payload);
    switch (status) {
      case 200:
        final eventIds = events.map((e) => e.id).toList();
        await store.delete(eventIds);

        numEvents = null;
        if (backoff) {
          backoff = false;
        }
        break;
      case 413:
        backoff = true;
        numEvents = numEvents ~/ 2;
        break;
      default:
      // error
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
