import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../main.dart';
import '../Normal_map.dart';
import '../color/config_model.dart';
import '../httpurl.dart';
import '../normalhttp.dart';
import '../sp_utils.dart';

class FollowupViewModel extends GetxController {
  final _configController = StreamController<ConfigModel>.broadcast();
  final _followResultController = StreamController<bool>.broadcast();
  final _loadingController = StreamController<bool>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  Stream<ConfigModel> get configData => _configController.stream;

  Stream<bool> get followResult => _followResultController.stream;

  Stream<bool> get loading => _loadingController.stream;

  Stream<String> get error => _errorController.stream;

  BuildContext? _context;
  final https = NormalHttp();
  final SpUtils _spUtils = SpUtils();

  // 设置上下文
  void setContext(BuildContext context) {
    _context = context;
  }

  // 清除上下文
  void disposeContext() {
    _context = null;
  }

  /// 获取配置
  Future<void> getConfig() async {
    try {
      _loadingController.add(true);

      /*    final response = await _apiService.getConfig();

      if (response['code'] == 200) {
        ConfigModel config = ConfigModel.fromJson(response['data']);
        _configController.add(config);
      } else {
        _errorController.add(response['message'] ?? 'Failed to load config');
        if (_context != null) {
          EasyLoading.showError(response['message'] ?? 'Failed to load config');
        }
      }*/

      NormalMap model = await https.post({}, caseQueryUrl);

      var s = model.toJson();
      debugPrint('contactInfo: $s');
      if (model.code == 0) {
        ConfigModel config = ConfigModel.fromJson(model.data);
        _configController.add(config);

        // LogUtil.json('API Response', model.data);
      } else {
        if (model.code == 401) {
          _spUtils.putString('token', '');
          _spUtils.putInt('login_status', 0);
          if (_context != null && _context!.mounted) {
            /*   Navigator.of(_context!).pushNamedAndRemoveUntil(
             '/login',
                 (route) => false,
           );*/
            Navigator.pushAndRemoveUntil(
              _context!,
              MaterialPageRoute(builder: (context) => MyHomePage(title: '')),
              (route) => false,
            );
          }
          //  Get.offAllNamed('/login');
        }

        EasyLoading.showError(model.msg);
      }
    } catch (e) {
      _errorController.add('Network error: $e');
      if (_context != null) {
        EasyLoading.showError('Network error: $e');
      }
    } finally {
      _loadingController.add(false);
    }
  }

  /// 提交跟进
  Future<void> follow({
    required String tradeNo,
    required String collectionNo,
    required String followId,
    required String followUp,
    required String mobile,
    required String name,
    required String collectionStatus,
    required String relation,
    required String content,
  }) async {
    try {
      _loadingController.add(true);

      /*  final response = await _apiService.follow(
        tradeNo: tradeNo,
        collectionNo: collectionNo,
        followId: followId,
        followUp: followUp,
        mobile: mobile,
        name: name,
        collectionStatus: collectionStatus,
        relation: relation,
        content: content,
      );

      if (response['code'] == 200) {
        _followResultController.add(true);
      } else {
        _errorController.add(response['message'] ?? 'Failed to submit follow up');
        if (_context != null) {
          EasyLoading.showError(response['message'] ?? 'Failed to submit follow up');
        }
      }*/

      NormalMap model = await https.post({
        collectionNo: collectionNo,
        followId: followId,
        followUp: followUp,
        mobile: mobile,
        name: name,
        collectionStatus: collectionStatus,
        relation: relation,
        content: content,
      }, phoneRecordAddUrl);

      if (model.code == 0) {
        _followResultController.add(true);
      } else {
        if (model.code == 401) {
          _spUtils.putString('token', '');
          _spUtils.putInt('login_status', 0);
          if (_context != null && _context!.mounted) {
            /*   Navigator.of(_context!).pushNamedAndRemoveUntil(
             '/login',
                 (route) => false,
           );*/
            Navigator.pushAndRemoveUntil(
              _context!,
              MaterialPageRoute(builder: (context) => MyHomePage(title: '')),
              (route) => false,
            );
          }
          //  Get.offAllNamed('/login');
        }

        EasyLoading.showError(model.msg);
      }
    } catch (e) {
      _errorController.add('Network error: $e');
      if (_context != null) {
        EasyLoading.showError('Network error: $e');
      }
    } finally {
      _loadingController.add(false);
    }
  }

  @override
  void onClose() {
    _configController.close();
    _followResultController.close();
    _loadingController.close();
    _errorController.close();
    super.onClose();
  }
}
