import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AppPreferences {
  Future<Locale?> loadLocale();

  Future<void> saveLocale(Locale locale);

  Future<String?> loadProductSerialNumber();

  Future<void> saveProductSerialNumber(String serialNumber);

  Future<void> clearProductSerialNumber();

  Future<String?> loadHairProfileResponse();

  Future<void> saveHairProfileResponse(String response);

  Future<String?> loadCurlTimingSettings();

  Future<void> saveCurlTimingSettings(String response);

  Future<void> clearCurlTimingSettings();
}

class SharedAppPreferences implements AppPreferences {
  SharedAppPreferences(this._preferences);

  static const _languageCodeKey = 'locale_language_code';
  static const _countryCodeKey = 'locale_country_code';
  static const _productSerialNumberKey = 'product_serial_number';
  static const _hairProfileResponseKey = 'hair_profile_response';
  static const _curlTimingSettingsKey = 'curl_timing_settings';

  final SharedPreferencesAsync _preferences;

  @override
  Future<Locale?> loadLocale() async {
    final languageCode = await _preferences.getString(_languageCodeKey);
    final countryCode = await _preferences.getString(_countryCodeKey);
    if (languageCode == null || languageCode.isEmpty) {
      return null;
    }
    if (countryCode == null || countryCode.isEmpty) {
      return Locale(languageCode);
    }
    return Locale(languageCode, countryCode);
  }

  @override
  Future<void> saveLocale(Locale locale) async {
    await _preferences.setString(_languageCodeKey, locale.languageCode);
    final countryCode = locale.countryCode;
    if (countryCode == null || countryCode.isEmpty) {
      await _preferences.remove(_countryCodeKey);
      return;
    }
    await _preferences.setString(_countryCodeKey, countryCode);
  }

  @override
  Future<String?> loadProductSerialNumber() {
    return _preferences.getString(_productSerialNumberKey);
  }

  @override
  Future<void> saveProductSerialNumber(String serialNumber) {
    return _preferences.setString(_productSerialNumberKey, serialNumber);
  }

  @override
  Future<void> clearProductSerialNumber() {
    return _preferences.remove(_productSerialNumberKey);
  }

  @override
  Future<String?> loadHairProfileResponse() {
    return _preferences.getString(_hairProfileResponseKey);
  }

  @override
  Future<void> saveHairProfileResponse(String response) {
    return _preferences.setString(_hairProfileResponseKey, response);
  }

  @override
  Future<String?> loadCurlTimingSettings() {
    return _preferences.getString(_curlTimingSettingsKey);
  }

  @override
  Future<void> saveCurlTimingSettings(String response) {
    return _preferences.setString(_curlTimingSettingsKey, response);
  }

  @override
  Future<void> clearCurlTimingSettings() {
    return _preferences.remove(_curlTimingSettingsKey);
  }
}
