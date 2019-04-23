import 'package:flutter_test/flutter_test.dart';

import 'package:amplitude_flutter/src/event.dart';
import 'package:amplitude_flutter/src/event_buffer.dart';

import 'matchers.dart';
import 'mock_client.dart';
import 'mock_store.dart';

void main() {
  group('EventBuffer', () {
    EventBuffer subject;
    MockClient client;
    MockStore store;

    setUp(() {
      client = MockClient();
      store = MockStore();
      subject = EventBuffer.private(client, store);
    });

    group('.length', () {
      test('returns the length of events in the store', () async {
        expect(subject.length, equals(0));

        await subject.add(Event('event 1'));
        expect(subject.length, equals(1));

        await subject.add(Event('event 2'));
        expect(subject.length, equals(2));
      });
    });

    group('.add', () {
      test('adds an event to the store, and adds a timestamp property',
          () async {
        await subject.add(Event('event 1'));
        expect(subject.length, equals(1));

        final List<Event> events = await subject.fetch(1);
        final Event event = events[0];

        expect(event.timestamp, isInstanceOf<int>());
      });

      test('flushes the buffer when the buffer size is reached', () async {
        subject = EventBuffer.private(client, store, size: 2);

        await subject.add(Event('flush test'));
        expect(client.postCallCount, equals(0));

        await subject.add(Event('event 2'));
        expect(client.postCallCount, equals(1));
        expect(subject.length, equals(2));

        expect(
            client.postCalls.single.first,
            ContainsSubMap(<String, dynamic>{
              'event_type': 'flush test',
              'timestamp': isInstanceOf<int>()
            }));
        expect(client.postCalls.single, isList);
      });
    });

    group('.fetch', () {
      test('returns a specified number of the oldest events in the store',
          () async {
        expect(subject.length, equals(0));

        await subject.add(Event('event 1'));
        await subject.add(Event('event 2'));
        await subject.add(Event('event 3'));
        expect(subject.length, equals(3));

        final List<Event> firstTwoEvents = await subject.fetch(2);
        expect(firstTwoEvents.length, equals(2));
        expect(firstTwoEvents[0].name, equals('event 1'));
        expect(firstTwoEvents[1].name, equals('event 2'));

        final List<Event> lastEvent = await subject.fetch(1);
        expect(lastEvent.length, equals(1));
        expect(lastEvent[0].name, equals('event 1'));

        expect(subject.length, equals(3));
      });

      test('works with numbers greater than the event count', () async {
        await subject.add(Event('event 1'));
        await subject.add(Event('event 2'));
        expect(subject.length, equals(2));

        final List<Event> poppedEvents = await subject.fetch(100);
        expect(poppedEvents.length, equals(2));
      });
    });
  });
}
