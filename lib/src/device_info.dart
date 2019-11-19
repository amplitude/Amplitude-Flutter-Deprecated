import 'dart:developer' as developer;
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:package_info/package_info.dart';

import './sim_info.dart';

class DeviceInfo {
  DeviceInfo(this.getCarrierInfo);
  bool getCarrierInfo;
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, String> _deviceData = <String, String>{};
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
        deviceData.addAll(await _getDeviceModel());
      }
      deviceData.addAll(await _getApplicationInfo());
      if (getCarrierInfo == true) {
        deviceData.addAll(await _getCarrierName());
      }
    } catch (e) {
      // error
    }
    _deviceData = deviceData;
    return deviceData;
  }

  Future<Map<String, String>> _getCarrierName() async {
    final String name = await SimInfo.getCarrierName;
    return <String, String>{'carrier': name};
  }

  // get iOS phone model
  Future<Map<String, String>> _getDeviceModel() async {
    final String name = await SimInfo.getDeviceModel;
    return <String, String>{'device_model': name};
  }

  Map<String, String> _parseAndroidInfo(AndroidDeviceInfo build) {
    developer.log('buildDataAndroid", $build');
    return <String, String>{
      'os_name': 'Android ${build.version.release}',
      'device_brand': build.brand,
      'device_manufacturer': build.manufacturer,
      'device_model': build.model,
      'device_id': build.androidId,
      'android_id': build.androidId,
      'platform': 'Android'
    };
  }

  Map<String, String> _parseIosInfo(IosDeviceInfo data) {
    developer.log('buildDataIos", $data');
    return <String, String>{
      'os_name': data.systemName,
      'os_version': data.systemVersion,
      'device_brand': null,
      'device_manufacturer': 'Apple',
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
