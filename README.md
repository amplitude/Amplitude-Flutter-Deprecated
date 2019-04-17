# amplitude_flutter

Amplitude SDK for Flutter.

## Usage

```dart
import 'package:amplitude_flutter/amplitude_flutter.dart';

Future<void> example() async {
  final AmplitudeFlutter analytics =  AmplitudeFlutter('API KEY');

  // log an event
  await analytics.logEvent(name: 'Dart Click');

  // identify a user
  final Identify identify = Identify()
    ..set('cohort', 'Test A')
    ..setOnce('completed_onboarding', 'true')
    ..add('login_count', 1)
    ..append('tags', 'new tag')
    ..unset('demo_user');

  await analytics.identify(identify);
}
```
