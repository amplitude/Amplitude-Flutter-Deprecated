import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class AmplitudeFlutter {
  static const MethodChannel _channel =
      const MethodChannel('amplitude_flutter');

  Future<void> logEvent({@required String name}) async {
    return _channel.invokeMethod('logEvent', <String, dynamic>{
      'name': name
    });
  }
}
