import 'dart:async';
import 'package:flutter/services.dart';

class DeviceInfoHelper {
  static const MethodChannel _channel =
      const MethodChannel('amplitude_flutter');

  static Future<String> get getCarrierName async {
    try {
      final String carrierName = await _channel.invokeMethod('carrierName');
      return carrierName;
    } on PlatformException catch (e) {
      print('error retreiving carrier info: ${e.message}');
      return '';
    }
  }

  /// Returns a [List] of locales from the device
  /// the first in the list should be the current one set on the device
  /// for example iOS **['en-GB', 'es-GB'] or for Android **['en_GB, 'es_GB]**
  static Future<List> get preferredLanguages async {
    final List version = await _channel.invokeMethod('preferredLanguages');
    return version;
  }

  /// Returns a [String] of the currently set DEVICE locale made up of the language and the region
  /// (e.g. en-US or en_US)
  static Future<String> get currentLocale async {
    final String locale = await _channel.invokeMethod('currentLocale');
    return locale;
  }

  /// Returns a [String] for adverstingId.
  /// iOS: idfa
  /// Android: androidADID
  static Future<String> get advertisingId async {
    final String advertisingId = await _channel.invokeMethod('advertisingId');
    return advertisingId;
  }

  /// Returns a [String] for deviceModel.
  /// This is only for iOS, android not needed.
  static Future<String> get deviceModel async {
    final String deviceModel = await _channel.invokeMethod('deviceModel');
    return deviceModel;
  }
}
