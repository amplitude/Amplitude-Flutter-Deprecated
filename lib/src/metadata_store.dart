import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

class MetadataStore {
  factory MetadataStore() => _instance ??= MetadataStore._();
  MetadataStore._() {
  }

  static MetadataStore _instance;

  Future<void> setDeviceId(String deviceId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(Constants.kLocalStoreDeviceIdKey, deviceId);
  }
  
  Future<String> getDeviceId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(Constants.kLocalStoreDeviceIdKey);
  }
}
