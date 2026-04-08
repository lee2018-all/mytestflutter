import 'package:pointycastle/asn1.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpUtils {
  static final SpUtils _instance = SpUtils._internal();
  factory SpUtils() => _instance;
  SpUtils._internal();

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _getPrefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<bool> getBool(String key, [bool defaultValue = false]) async {
    final prefs = await _getPrefs;
    return prefs.getBool(key) ?? defaultValue;
  }

  Future<void> putBool(String key, bool value) async {
    final prefs = await _getPrefs;
    await prefs.setBool(key, value);
  }

  Future<String> getString(String key, [String defaultValue = '']) async {
    final prefs = await _getPrefs;
    return prefs.getString(key) ?? defaultValue;
  }

  Future<void> putString(String key, String value) async {
    final prefs = await _getPrefs;
    await prefs.setString(key, value);
  }
  Future<int> getInt(String key, [int defaultValue = 0]) async {
    final prefs = await _getPrefs;
    return prefs.getInt(key) ?? defaultValue;
  }

  Future<void> putInt(String key, int value) async {
    final prefs = await _getPrefs;
    await prefs.setInt(key, value);
  }
}