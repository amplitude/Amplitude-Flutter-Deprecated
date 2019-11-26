import 'dart:async';

import 'package:flutter/services.dart';

class SimInfo {
  static const MethodChannel _channel =
      const MethodChannel('amplitude_flutter');

  static Future<String> get getCarrierName async {
    try {
      final String carrierName  = await _channel.invokeMethod('carrierName');
      return carrierName;
    } on PlatformException catch(e) {
      print('error retreiving carrier info: ${e.message}');
      return '';
    }
  }

// retreives the model type for the device
  static Future<String> get getDeviceModel async {
    final String deviceModel = await _channel.invokeMethod('deviceModel');
    return deviceModel;
  }
}
