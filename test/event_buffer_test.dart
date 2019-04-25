import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:amplitude_flutter/src/client.dart';
import 'package:amplitude_flutter/src/event.dart';
import 'package:amplitude_flutter/src/event_buffer.dart';
import 'package:amplitude_flutter/src/store.dart';

import 'matchers.dart';
import 'mock_client.dart';
import 'mock_service_provider.dart';

class MockitoClient extends Mock implements Client {}

class MockitoStore extends Mock implements Store {}

void main() {
  group('EventBuffer', () {
    MockServiceProvider provider;
    MockClient client;

    EventBuffer subject;

    setUp(() {
      provider = MockServiceProvider();
      client = provider.client;
      subject = EventBuffer(provider);
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
        subject = EventBuffer(provider, size: 2);

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

    group('.flush', () {
      Client mockClient;
      Store mockStore;

      setUp(() {
        mockClient = MockitoClient();
        mockStore = MockitoStore();
        provider = MockServiceProvider(client: mockClient, store: mockStore);
        subject = EventBuffer(provider);

        final events = [Event('flush 1', id: 1), Event('flush 2', id: 2)];

        when(mockStore.length).thenReturn(events.length);
        when(mockStore.fetch(any)).thenAnswer((_) => Future.value(events));
      });

      test('deletes events on success', () async {
        when(mockClient.post(any)).thenAnswer((_) => Future.value(true));

        await subject.flush();

        verify(mockClient.post(any)).called(1);
        verify(mockStore.delete([1, 2])).called(1);
      });

      test('does not delete events on failure', () async {
        when(mockClient.post(any)).thenAnswer((_) => Future.value(false));

        await subject.flush();

        verify(mockClient.post(any)).called(1);
        verifyNever(mockStore.delete(any));
      });
    });
  });
}
