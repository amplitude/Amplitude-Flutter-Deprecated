import 'dart:developer' as developer;
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:package_info/package_info.dart';
import 'package:uuid/uuid.dart';

import './device_info_helper.dart';

class DeviceInfo {
  DeviceInfo(this.getCarrierInfo);
  bool getCarrierInfo;
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, String> _deviceData = <String, String>{};
  Map<String, String> _advData = <String, String>{};

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
      deviceData.addAll(await _getCurrentLocale());
      if (getCarrierInfo == true) {
        deviceData.addAll(await _getCarrierName());
      }
    } catch (e) {
      // error
    }
    _deviceData = deviceData;
    return deviceData;
  }

  Future<Map<String, String>> getAdvertisingInfo() async {
    if (_advData.isNotEmpty) {
      return _advData;
    }

    final String advertisingId = await DeviceInfoHelper.advertisingId;
    if (advertisingId == null) {
      _advData = <String, String>{};
      return _advData;
    }

    if (Platform.isAndroid) {
      _advData = <String, String> { 'androidADID': advertisingId };
    } else if (Platform.isIOS) {
      _advData = <String, String> {
        'ios_idfa': advertisingId,
        'ios_idfv': (await deviceInfoPlugin.iosInfo).identifierForVendor
      };
    } else {
      _advData = <String, String>{};
    }

    return _advData;
  }

  Future<Map<String, String>> _getCarrierName() async {
    final String name = await DeviceInfoHelper.getCarrierName;
    if (name != null && name.isNotEmpty) {
      return <String, String>{'carrier': name};
    } else {
      return <String, String>{};
    }
  }

  // get iOS phone model
  Future<Map<String, String>> _getDeviceModel() async {
    final String name = await DeviceInfoHelper.getDeviceModel;
    return <String, String>{'device_model': name};
  }

  Future<Map<String, String>> _getCurrentLocale() async {
    final String name = await DeviceInfoHelper.currentLocale;
    return <String, String>{'language': name};
  }

  Map<String, String> _parseAndroidInfo(AndroidDeviceInfo build) {
    developer.log('buildDataAndroid", $build');
    return <String, String>{
      'os_name': 'Android ${build.version.release}',
      'device_brand': build.brand,
      'device_manufacturer': build.manufacturer,
      'device_model': build.model,
      'device_id': build.androidId,
      'platform': 'Android'
    };
  }

  Map<String, String> _parseIosInfo(IosDeviceInfo data) {
    developer.log('buildDataIos", $data');
    String deviceId = data.identifierForVendor;
    if (deviceId == null || deviceId == '00000000-0000-0000-0000-000000000000') {
      deviceId = Uuid().v4() + 'R';
    }
    return <String, String>{
      'os_name': data.systemName,
      'os_version': data.systemVersion,
      'device_brand': null,
      'device_manufacturer': 'Apple',
      'device_id': deviceId,
      'platform': 'iOS'
    };
  }

  Future<Map<String, String>> _getApplicationInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();

    return <String, String>{'version_name': info.version};
  }
}
