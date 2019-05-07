import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:package_info/package_info.dart';

class DeviceInfo {
  DeviceInfo() {
    getPlatformInfo();
  }

  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, String> _deviceData = <String, String>{};

  Map<String, String> get() {
    return _deviceData;
  }

  Future<Map<String, String>> getPlatformInfo() async {
    if (_deviceData.isNotEmpty) {
      return _deviceData;
    }

    Map<String, String> deviceData;
    try {
      if (Platform.isAndroid) {
        deviceData = _parseAndroidInfo(await deviceInfoPlugin.androidInfo);
      } else if (Platform.isIOS) {
        deviceData = _parseIosInfo(await deviceInfoPlugin.iosInfo);
      }
      deviceData.addAll(await _getApplicationInfo());
    } catch (e) {
      // error
    }
    _deviceData = deviceData;
    return deviceData;
  }

  Map<String, String> _parseAndroidInfo(AndroidDeviceInfo build) {
    return <String, String>{
      'os_name': build.version.baseOS,
      'device_brand': build.brand,
      'device_model': build.device,
      'device_id': build.androidId,
      'android_id': build.androidId,
      'platform': 'Android'
    };
  }

  Map<String, String> _parseIosInfo(IosDeviceInfo data) {
    return <String, String>{
      'os_name': data.systemName,
      'os_version': data.systemVersion,
      'device_brand': data.name,
      'device_model': data.model,
      'device_id': data.identifierForVendor,
      'idfv': data.identifierForVendor,
      'platform': 'iOS'
    };
  }

  Future<Map<String, String>> _getApplicationInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();

    return <String, String>{'version_name': info.version};
  }
}
