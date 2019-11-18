import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

class SimInfo {
  static const MethodChannel _channel =
      const MethodChannel('amplitude_flutter');

  static Future<String> get getCarrierName async {
    final String carrierName  = await _channel.invokeMethod('carrierName');
    print(carrierName);
    return carrierName;
  }

  static Future<String> get getDeviceModel async {
    final String deviceModel = await _channel.invokeMethod('deviceModel');
    print("deviceModel");
    print(deviceModel);
    return deviceModel;
  }
}
