import 'dart:developer' as developer;
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:package_info/package_info.dart';
import 'package:uuid/uuid.dart';

import 'constants.dart';
import 'device_info_helper.dart';
import 'metadata_store.dart';

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
        deviceData = await _parseAndroidInfo(await deviceInfoPlugin.androidInfo);
      } else if (Platform.isIOS) {
        deviceData = await _parseIosInfo(await deviceInfoPlugin.iosInfo);
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
        Constants.kPayloadIosIdfa: advertisingId,
        Constants.kPayloadIosIdfv: (await deviceInfoPlugin.iosInfo).identifierForVendor
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

  Future<Map<String, String>> _getCurrentLocale() async {
    final String name = await DeviceInfoHelper.currentLocale;
    return <String, String>{'language': name};
  }

  Future<Map<String, String>> _parseAndroidInfo(AndroidDeviceInfo build) async {
    developer.log('buildDataAndroid", $build');
    
    String deviceId = await MetadataStore().getDeviceId();

    // If deviceId is null and invalid, we will use AAID or
    // generate a NEW random number followed by 'R'
    if (deviceId == null || Constants.kInvalidAndroidDeviceIds.contains(deviceId)) {
      deviceId = _advData[Constants.kPayloadAndroidAaid];
      deviceId ??= Uuid().v4() + 'R';

      // Persist deviceId locally.
      MetadataStore().setDeviceId(deviceId);
    }

    return <String, String>{
      'os_name': 'android',
      'os_version': build.version.release,
      'device_brand': build.brand,
      'device_manufacturer': build.manufacturer,
      'device_model': build.model,
      'device_id': deviceId,
      'platform': 'Android'
    };
  }

  Future<Map<String, String>> _parseIosInfo(IosDeviceInfo data) async {
    developer.log('buildDataIos", $data');

    String deviceId = await MetadataStore().getDeviceId();

    // If deviceId is null and invalid, we will use idfa or
    // generate a NEW random number followed by 'R'
    if (deviceId == null || Constants.kInvalidIosDeviceIds.contains(deviceId)) {
      deviceId = _advData[Constants.kPayloadIosIdfa];
      deviceId ??= Uuid().v4() + 'R';

      // Persist deviceId locally.
      MetadataStore().setDeviceId(deviceId);
    }

    return <String, String>{
      'os_name': data.systemName,
      'os_version': data.systemVersion,
      'device_brand': null,
      'device_manufacturer': 'Apple',
      'device_model': data.model,
      'device_id': deviceId,
      'platform': 'iOS'
    };
  }

  Future<Map<String, String>> _getApplicationInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();

    return <String, String>{'version_name': info.version};
  }
}
